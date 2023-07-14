from abc import ABC, abstractmethod

from apscheduler.schedulers.background import BackgroundScheduler

from DBController.BaseDBController import BaseDBController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotModel import PilotModel
from common.Thread import ValueThread


class Event(ABC):
    def __init__(self, config):
        self.config = config


class PeriodTrainingEvent(Event, ABC):
    def __init__(self, config, per_query_count, model: PilotModel):
        super().__init__(config)
        self.per_query_count = per_query_count
        self.query_count = 0
        self.model = model

    def update(self, pilot_data_manager: PilotTrainDataManager):
        self.query_count += 1
        if self.query_count >= self.per_query_count:
            self.query_count = 0
            self.model.user_model = self.custom_update(self.model.user_model, pilot_data_manager)

    @abstractmethod
    def custom_update(self, user_model, pilot_data_manager: PilotTrainDataManager):
        pass


class PeriodCollectionDataEvent(Event):

    def __init__(self, config, seconds):
        super().__init__(config)
        self._table_name = self.get_table_name()
        self._seconds = seconds
        self._training_data_manager = PilotTrainDataManager(config)
        self._scheduler = scheduler = BackgroundScheduler()

        scheduler.add_job(self._trigger, "interval", seconds=self._seconds)

    def start(self):
        self._scheduler.start()

    def _trigger(self):
        column_2_value = self.custom_collect()
        self._training_data_manager.save_data(self._table_name, column_2_value)

    def stop(self):
        self._scheduler.shutdown()

    @abstractmethod
    def get_table_name(self):
        pass

    @abstractmethod
    def custom_collect(self) -> dict:
        pass


class PeriodPerCountCollectionDataEvent(Event):

    def __init__(self, save_table_name, config, per_query_count):
        super().__init__(config)
        self._training_data_manager = PilotTrainDataManager(config)
        self.per_query_count = per_query_count
        self.query_count = 0
        self._table_name = save_table_name

    def update(self):
        self.query_count += 1
        if self.query_count >= self.per_query_count:
            self.query_count = 0
            self._trigger()

    def _trigger(self):
        column_2_value = self.custom_collect()
        self._training_data_manager.save_data_batch(self._table_name, column_2_value)

    @abstractmethod
    def custom_collect(self) -> dict:
        pass


class ContinuousCollectionDataEvent(Event):
    def __init__(self, config):
        super().__init__(config)
        self._table_name = self.get_table_name()
        self._training_data_manager = PilotTrainDataManager(config)

    def start(self):
        while self.has_next():
            column_2_value = self.next()
            self._training_data_manager.save_data(self._table_name, column_2_value)

    @abstractmethod
    def get_table_name(self):
        pass

    @abstractmethod
    def has_next(self):
        pass

    @abstractmethod
    def next(self) -> dict:
        pass


class PretrainingModelEvent(Event):
    def __init__(self, config: PilotConfig, bind_model: PilotModel, save_table_name, enable_collection=True,
                 enable_training=True):
        super().__init__(config)
        self.config = config
        self._model: PilotModel = bind_model
        self._train_data_manager = PilotTrainDataManager(config)
        self.enable_collection = enable_collection
        self.enable_training = enable_training
        self.save_table_name = save_table_name

    def async_start(self):
        t = ValueThread(target=self._run, name="pretraining_async_start")
        t.daemon = True
        t.start()
        return t

    def _run(self):
        self.collect_and_write()
        self.train()

    def collect_and_write(self):
        is_terminate = False
        if self.enable_collection:
            while not is_terminate:
                column_2_value_list, is_terminate = self._custom_collect_data()
                table = self.save_table_name
                self._train_data_manager.save_data_batch(table, column_2_value_list)

    def train(self):
        if self.enable_training:
            self._model.user_model = self._custom_pretrain_model(self._train_data_manager, self._model.user_model)
            self._model.save()

    @abstractmethod
    def _custom_collect_data(self):
        pass

    @abstractmethod
    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        pass


class PeriodicDbControllerEvent(Event):
    def __init__(self, config, per_query_count, exec_in_init=True):
        super().__init__(config)
        self.per_query_count = per_query_count
        self._cur_query_count = per_query_count if exec_in_init else 0
        self._db_controller = DBControllerFactory.get_db_controller(config)
        self._training_data_manager = PilotTrainDataManager(config)

    def update(self):
        self._cur_query_count += 1
        if self._cur_query_count >= self.per_query_count:
            self._cur_query_count = 0
            self._custom_update(self._db_controller, self._training_data_manager)

    @abstractmethod
    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):
        pass
