from abc import ABC, abstractmethod

from apscheduler.schedulers.background import BackgroundScheduler

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotModel import PilotModel
from pilotscope.Common.Thread import ValueThread


class Event(ABC):
    def __init__(self, config):
        self.config = config


class QueryFinishEvent(Event, ABC):
    """
     THe process function will be called when "interval_count" query is finished.
    """

    def __init__(self, config, interval_count=1):
        super().__init__(config)
        self.interval_count = interval_count
        self.query_execution_count = 0

    def update(self, db_controller: BaseDBController, pilot_data_manager: PilotTrainDataManager):
        """
        This function will be called when a query is finished.
        It will call process function when "interval_count" query is finished.
        :return:
        """
        self.query_execution_count += 1
        if self.query_execution_count >= self.interval_count:
            self.query_execution_count = 0
            self.process(db_controller, pilot_data_manager)

    @abstractmethod
    def process(self, db_controller: BaseDBController, pilot_data_manager: PilotTrainDataManager):
        pass


class PeriodicModelUpdateEvent(QueryFinishEvent, ABC):
    """
    The user can inherit this class to implement a periodic model update event.
    """

    def __init__(self, config, interval_count, pilot_model: PilotModel, execute_before_first_query=True):
        super().__init__(config, interval_count)
        self.pilot_model = pilot_model
        self.execute_before_first_query = execute_before_first_query

    def process(self, db_controller: BaseDBController, pilot_data_manager: PilotTrainDataManager):
        self.pilot_model.model = self.custom_model_update(self.pilot_model.model, pilot_data_manager)
        self.pilot_model.save()

    @abstractmethod
    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            pilot_data_manager: PilotTrainDataManager):
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
            self._model.model = self._custom_pretrain_model(self._train_data_manager, self._model.model)
            self._model.save()

    @abstractmethod
    def _custom_collect_data(self):
        pass

    @abstractmethod
    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        pass
