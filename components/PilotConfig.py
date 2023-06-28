import os

from PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode
import logging

# 配置日志记录器
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
pilot_logger = logging.getLogger("PilotScope")


class PilotConfig:

    def __init__(self) -> None:
        self.db_type: DatabaseEnum = DatabaseEnum.POSTGRESQL
        self.pilotscope_core_url = "localhost"
        self.host = "localhost"
        self.user = "postgres"
        self.db = "stats"
        self.SEP = "###"
        self.data_fetch_method = DataFetchMethodEnum.HTTP

        # ms
        self.sql_execution_timeout = 30
        self.once_request_timeout = self.sql_execution_timeout

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

    def set_db_type(self, db):
        self.db_type = db
        pass
