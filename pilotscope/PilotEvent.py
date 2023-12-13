from abc import ABC, abstractmethod

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotModel import PilotModel
from pilotscope.Common.Thread import ValueThread


class Event(ABC):
    """
    Abstract base class for an event.

    This class provides the base structure for different event types in an application,
    and is meant to be subclassed to create concrete event implementations.
    """

    def __init__(self, config):
        """

        :param config: The configuration of PilotScope.
        """
        self.config = config


class QueryFinishEvent(Event, ABC):
    """
     THe process function will be called when `interval_count` query is finished.
    """

    def __init__(self, config, interval_count=1):
        """

        :param config: The configuration of PilotScope.
        :param interval_count: This event will be triggered when per `interval_count` query is finished.
        """
        super().__init__(config)
        self.interval_count = interval_count
        self.query_execution_count = 0

    def _update(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        This function will be called when a query is finished.
        It will call process function when `interval_count` query is finished.
        """
        self.query_execution_count += 1
        if self.query_execution_count >= self.interval_count:
            self.query_execution_count = 0
            self.process(db_controller, data_manager)

    @abstractmethod
    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        This function will be called when `interval_count` query is finished.
        The user can implement the function to define the process logic.

        :param db_controller: A `db_controller` initialized by the user's `PilotConfig` registered in `PilotScheduler`.
        :param data_manager: A `data_manager` initialized by the user's `PilotConfig` registered in `PilotScheduler`.
        """
        pass


class WorkloadBeforeEvent(Event, ABC):
    """
    The process function will be called before start to deal with first SQL query of a workload.
    """

    def __init__(self, config, enable=True):
        """

        :param config: The configuration of PilotScope.
        :param enable: The event will be triggered when the value is True.
        """
        super().__init__(config)
        self.already_been_called = not enable

    def _update(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        Updates the event state and triggers the processing of the event.
        This method sets the `already_been_called` flag to True to indicate the event has been
        updated and then calls the `process` method to handle the event using the given
        `db_controller` and `data_manager`.

        :param db_controller: The database controller to be used for database operations during event processing.
        :type db_controller: BaseDBController
        :param data_manager: The data manager to be used for data handling during event processing.
        :type data_manager: DataManager
        """
        self.already_been_called = True
        self.process(db_controller, data_manager)

    @abstractmethod
    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        This function will be called before start to deal with first SQL query of a workload, i.e., the first call
        `PilotScheduler.execute()`.
        The user can implement the function to define the process logic.

        :param db_controller: A `db_controller` initialized by the user's `PilotConfig` registered in `PilotScheduler`.
        :param data_manager: A `data_manager` initialized by the user's `PilotConfig` registered in `PilotScheduler`.
        """
        pass


class PeriodicModelUpdateEvent(QueryFinishEvent, ABC):
    """
    The user can inherit this class to implement a periodic model update event.
    """

    def __init__(self, config, interval_count, pilot_model: PilotModel = None, execute_on_init=True):
        """

        :param config: The configuration of PilotScope.
        :param interval_count: This event will be triggered when per `interval_count` query is finished.
        :param pilot_model: The pilot model to be updated.
        :param execute_on_init: Whether to execute the `custom_model_update` function when the `PilotScheduler` is initialized.
        """
        super().__init__(config, interval_count)
        self.pilot_model = pilot_model
        self.execute_before_first_query = execute_on_init

    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        model = self.custom_model_update(self.pilot_model, db_controller, data_manager)
        if self.pilot_model is not None:
            self.pilot_model.model = model
            self.pilot_model.save_model()

    @abstractmethod
    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            data_manager: DataManager):
        """
        The user can implement the function to define the process logic of model update.
        PilotScope will call this function periodically (i.e., per `interval_count` queries) for model update.
        You should to return the updated user model, then PilotScope will save it automatically.

        :param pilot_model: The pilot model to be updated.
        :param db_controller: The database controller to be used for the update operations.
        :param data_manager: The data manager that provides access to the application's data.
        :return: The updated user model (i.e., pilot_model.model).
        """
        pass


class PretrainingModelEvent(Event, ABC):
    """
    A pretraining model event is an event that is used to collect data nad pretrain a model before the application starts.
    """

    def __init__(self, config: PilotConfig, bind_pilot_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True):
        """

        :param config: The configuration of PilotScope.
        :param bind_pilot_model: The pilot model to be pre-trained.
        :param data_saving_table: The table to save the collected data.
        :param enable_collection: A flag indicating whether to enable data collection.
        :param enable_training: A flag indicating whether to enable model training.
        """
        super().__init__(config)
        self.config = config
        self._model: PilotModel = bind_pilot_model
        self.enable_collection = enable_collection
        self.enable_training = enable_training
        self.data_saving_table = data_saving_table

    def _async_start(self):
        """
        Starts the pretraining process asynchronously by launching a separate thread.
        This method creates a new ValueThread, sets it as a daemon thread, and starts it.
        This allows the pretraining process to run in the background, enabling the main
        application to continue running independently.

        :return: The ValueThread instance that has been started.
        :rtype: ValueThread
        """
        t = ValueThread(target=self._run, name="pretraining_async_start")
        t.daemon = True
        t.start()
        return t

    def _run(self):
        db_controller = DBControllerFactory.get_db_controller(self.config)
        data_manager = DataManager(self.config)
        self._collect_and_store_data(db_controller, data_manager)
        self._model_training(db_controller, data_manager)

    def _collect_and_store_data(self, db_controller: BaseDBController, data_manager: DataManager):
        """
        This function iteratively collects data from the database and stores it in the specified table.

        :param db_controller: The object that controls the database connection.
        :type db_controller: BaseDBController
        :param data_manager: The object that manages the collected data.
        :type data_manager: DataManager
        """
        is_terminate = False
        if self.enable_collection:
            while not is_terminate:
                column_2_value_list, is_terminate = self.iterative_data_collection(db_controller, data_manager)
                table = self.data_saving_table
                data_manager.save_data_batch(table, column_2_value_list)

    def _model_training(self, db_controller: BaseDBController, train_data_manager: DataManager):
        """
        If training is enabled, this function trains the model with custom training logic and saves it.

        :param db_controller: The object that controls the database connection.
        :type db_controller: BaseDBController
        :param train_data_manager: The object that manages the training data.
        :type train_data_manager: DataManager
        """
        if self.enable_training:
            self._model.model = self.custom_model_training(self._model.model, db_controller, train_data_manager)
            self._model.save_model()

    @abstractmethod
    def iterative_data_collection(self, db_controller: BaseDBController, train_data_manager: DataManager):
        """
        This user should implement this function to define the iterative process of custom data collection.
        Each iteration should return a list where each item is a dict indicating each column's name and value.
        All column names should be the same as the columns of `self.data_saving_table`.
        PilotScope will save these data into the specified table `self.data_saving_table` automatically.
        In addition, this function should return a bool value to indicate whether the iteration should be terminated.

        :param db_controller: The object that controls the database connection.
        :param train_data_manager: The object that manages the training data.
        :return two values: A list where each item is a dict indicate each column's value and a bool value indicate whether the iteration should be terminated.
        """
        pass

    @abstractmethod
    def custom_model_training(self, bind_pilot_model: PilotModel, db_controller: BaseDBController,
                              data_manager: DataManager):
        """
        This user should implement this function to define the custom logic for training the model.
        PilotScope will call this function after the data collection is finished.
        You should return the updated user model, then PilotScope will save it automatically.

        :param bind_pilot_model: The model to be trained.
        :param db_controller: The object that controls the database connection.
        :param data_manager: The object that manages the data used for training the model.
        :return: The updated user model (i.e., bind_pilot_model.model).
        """
        pass
