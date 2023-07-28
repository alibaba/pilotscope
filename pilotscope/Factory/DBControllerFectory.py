from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum


class DBControllerFactory:
    identifier_2_db_controller = {}

    @classmethod
    def get_db_controller(cls, config: PilotConfig, echo=False, allow_to_create_db=False, enable_simulate_index=False):
        identifier = cls._get_identifier(config, echo, allow_to_create_db, enable_simulate_index)

        if identifier in DBControllerFactory.identifier_2_db_controller:
            db_controller: BaseDBController = cls.identifier_2_db_controller[identifier]
            db_controller.connect_if_loss()
            return db_controller

        db_controller = None
        if config.db_type == DatabaseEnum.POSTGRESQL:
            from pilotscope.DBController.PostgreSQLController import PostgreSQLController
            db_controller = PostgreSQLController(config, echo, allow_to_create_db, enable_simulate_index)
        elif config.db_type == DatabaseEnum.SPARK:
            from pilotscope.DBController.SparkSQLController import SparkSQLController
            db_controller = SparkSQLController(config, echo, allow_to_create_db)
            pass
        else:
            raise RuntimeError()

        DBControllerFactory.identifier_2_db_controller[identifier] = db_controller
        return db_controller

    @classmethod
    def _get_identifier(cls, config: PilotConfig, echo=False, allow_to_create_db=False, enable_simulate_index=False):
        return "{}_{}".format(config, enable_simulate_index)
