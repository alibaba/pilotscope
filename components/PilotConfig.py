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

        # second
        self.sql_execution_timeout = 50
        self.once_request_timeout = self.sql_execution_timeout

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

        # training and test sql file
        self.training_sql_file = "../examples/stats_train.txt"
        self.test_sql_file = "../examples/stats_test.txt"

        # for local postgres
        self.pg_ctl = "pg_ctl"
        self.pgdata = "~"
        self.db_config_path = "/var/lib/pgsql/13.1/data/postgresql.conf"
        self.backup_db_config_path = "postgresql-13.1.conf"
        
    def set_db_type(self, db):
        self.db_type = db
        pass
