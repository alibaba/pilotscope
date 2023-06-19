from DBController.PostgreSQLController import PostgreSQLController
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum


class DBControllerFactory:
    @staticmethod
    def get_db_controller(config: PilotConfig, echo=False, allow_to_create_db=False):
        if config.db_type == DatabaseEnum.POSTGRESQL:
            return PostgreSQLController(config, echo, allow_to_create_db)
        else:
            raise RuntimeError()
