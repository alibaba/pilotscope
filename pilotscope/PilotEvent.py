from abc import ABC, abstractmethod

from apscheduler.schedulers.background import BackgroundScheduler

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DataManager.DataManager import DataManager
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

    def update(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        This function will be called when a query is finished.
        It will call process function when "interval_count" query is finished.
        :return:
        """
        self.query_execution_count += 1
        if self.query_execution_count >= self.interval_count:
            self.query_execution_count = 0
            self.process(db_controller, data_manager)

    @abstractmethod
    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        pass


class WorkloadBeforeEvent(Event, ABC):
    """
    The process function will be called before start to deal with first SQL query of a workload.
    """

    def __init__(self, config, enable=True):
        super().__init__(config)
        self.already_been_called = not enable

    def update(self, db_controller: BaseDBController, data_manager: DataManager):
        self.already_been_called = True
        self.process(db_controller, data_manager)

    @abstractmethod
    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        pass


class PeriodicModelUpdateEvent(QueryFinishEvent, ABC):
    """
    The user can inherit this class to implement a periodic model update event.
    """

    def __init__(self, config, interval_count, pilot_model: PilotModel = None, execute_on_init=True):
        super().__init__(config, interval_count)
        self.pilot_model = pilot_model
        self.execute_before_first_query = execute_on_init

    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        model = self.custom_model_update(self.pilot_model, db_controller, data_manager)
        if self.pilot_model is not None:
            self.pilot_model.model = model
            self.pilot_model.save()

    @abstractmethod
    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            data_manager: DataManager):
        pass


class PretrainingModelEvent(Event, ABC):
    def __init__(self, config: PilotConfig, bind_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True):
        super().__init__(config)
        self.config = config
        self._model: PilotModel = bind_model
        self.enable_collection = enable_collection
        self.enable_training = enable_training
        self.data_saving_table = data_saving_table

    def async_start(self):
        t = ValueThread(target=self._run, name="pretraining_async_start")
        t.daemon = True
        t.start()
        return t

    def _run(self):
        db_controller = DBControllerFactory.get_db_controller(self.config)
        data_manager = DataManager(self.config)
        self.collect_and_store_data(db_controller, data_manager)
        self.model_training(db_controller, data_manager)

    def collect_and_store_data(self, db_controller: BaseDBController, data_manager: DataManager):
        is_terminate = False
        if self.enable_collection:
            while not is_terminate:
                column_2_value_list, is_terminate = self.iterative_data_collection(db_controller, data_manager)
                table = self.data_saving_table
                data_manager.save_data_batch(table, column_2_value_list)

    def model_training(self, db_controller: BaseDBController, train_data_manager: DataManager):
        if self.enable_training:
            self._model.model = self.custom_model_training(self._model.model, db_controller, train_data_manager)
            self._model.save()

    @abstractmethod
    def iterative_data_collection(self, db_controller: BaseDBController, train_data_manager: DataManager):
        pass

    @abstractmethod
    def custom_model_training(self, bind_model, db_controller: BaseDBController,
                              data_manager: DataManager):
        pass
