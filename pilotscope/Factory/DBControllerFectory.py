import threading

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum

lock = threading.Lock()


class DBControllerFactory:
    _identifier_2_db_controller = {}

    @classmethod
    def get_db_controller(cls, config: PilotConfig, echo=False, enable_simulate_index=False):
        """
        Get a db controller instance based on the config.
        Each thread maintains a db controller instance with the same config.
        A new db controller instance will be created when the thread does not exist an instance or the config is different.

        :param config: The config of PilotScope.
        :param echo: Whether to print the SQL statement.
        :param enable_simulate_index: Whether to enable the simulated index. This is only valid for PostgreSQL.
        :return: A new or cached db controller instance.
        """
        lock.acquire()
        try:
            identifier = cls._get_identifier(config, enable_simulate_index)

            if identifier in DBControllerFactory._identifier_2_db_controller:
                db_controller: BaseDBController = cls._identifier_2_db_controller[identifier]
                db_controller._connect_if_loss()
                return db_controller

            if config.db_type == DatabaseEnum.POSTGRESQL:
                from pilotscope.DBController.PostgreSQLController import PostgreSQLController
                db_controller = PostgreSQLController(config, echo, enable_simulate_index)
            elif config.db_type == DatabaseEnum.SPARK:
                from pilotscope.DBController.SparkSQLController import SparkSQLController
                if enable_simulate_index:
                    raise RuntimeError("SparkSQL does not support simulate index")
                db_controller = SparkSQLController(config, echo)
                pass
            else:
                raise RuntimeError()
            DBControllerFactory._identifier_2_db_controller[identifier] = db_controller
            return db_controller
        finally:
            lock.release()

    @classmethod
    def _get_identifier(cls, config: PilotConfig, enable_simulate_index=False):
        return "{}_{}".format(config, enable_simulate_index)
