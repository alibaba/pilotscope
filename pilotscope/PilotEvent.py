from abc import ABC, abstractmethod

from apscheduler.schedulers.background import BackgroundScheduler

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
        self.config = config


class QueryFinishEvent(Event, ABC):
    """
     THe process function will be called when `interval_count` query is finished.
    """

    def __init__(self, config, interval_count=1):
        super().__init__(config)
        self.interval_count = interval_count
        self.query_execution_count = 0

    def update(self, db_controller: BaseDBController, data_manager: DataManager):
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
        Abstract method to process the event using a database controller and a data manager.
        Subclasses should implement this method to define the specific processing logic
        for the event based on the interactions with the provided `db_controller` and
        `data_manager`.

        :param db_controller: The database controller to be used for database operations.
        :type db_controller: BaseDBController
        :param data_manager: The data manager to be used for managing data during processing.
        :type data_manager: DataManager
        """
        pass


class WorkloadBeforeEvent(Event, ABC):
    """
    The process function will be called before start to deal with first SQL query of a workload.
    """

    def __init__(self, config, enable=True):
        super().__init__(config)
        self.already_been_called = not enable

    def update(self, db_controller: BaseDBController, data_manager: DataManager):
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
        Abstract method to define the processing logic for the event.
        This method must be implemented by subclasses to provide specific logic for how
        the event should be processed using the provided database controller and data manager.

        :param db_controller: The database controller to be used for any database operations required by the event.
        :type db_controller: BaseDBController
        :param data_manager: The data manager that provides access to the application's data.
        :type data_manager: DataManager
        """
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
            self.pilot_model.save_model()

    @abstractmethod
    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            data_manager: DataManager):
        """
        Abstract method for custom updates to the pilot model.
        This method must be implemented by subclasses to define specific update logic for the
        pilot model using the provided database controller and data manager. It is meant to
        be customized based on the event's needs and the state of the pilot model.

        :param pilot_model: The pilot model to be updated.
        :type pilot_model: PilotModel
        :param db_controller: The database controller to be used for the update operations.
        :type db_controller: BaseDBController
        :param data_manager: The data manager that provides access to the application's data.
        :type data_manager: DataManager
        """
        pass


class PretrainingModelEvent(Event, ABC):
    """
    Abstract base class representing pre-training events for a `PilotModel`.
    This class is responsible for managing the initial data collection and model training
    routines prior to the model being deployed in a production environment. It utilizes
    mechanisms for asynchronous data collection and model training.
    """
    def __init__(self, config: PilotConfig, bind_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True):
        super().__init__(config)
        self.config = config
        self._model: PilotModel = bind_model
        self.enable_collection = enable_collection
        self.enable_training = enable_training
        self.data_saving_table = data_saving_table

    def async_start(self):
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
        self.collect_and_store_data(db_controller, data_manager)
        self.model_training(db_controller, data_manager)

    def collect_and_store_data(self, db_controller: BaseDBController, data_manager: DataManager):
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

    def model_training(self, db_controller: BaseDBController, train_data_manager: DataManager):
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
        This abstract method defines the iterative process of collecting data from the database.

        :param db_controller: The object that controls the database connection.
        :type db_controller: BaseDBController
        :param train_data_manager: The object that manages the training data.
        :type train_data_manager: DataManager
        """
        pass

    @abstractmethod
    def custom_model_training(self, bind_model, db_controller: BaseDBController,
                              data_manager: DataManager):
        """
        This abstract method defines the custom logic for training the model.

        :param bind_model: The model to be trained.
        :type bind_model: Model
        :param db_controller: The object that controls the database connection.
        :type db_controller: BaseDBController
        :param data_manager: The object that manages the data used for training the model.
        :type data_manager: DataManager
        """
        pass
