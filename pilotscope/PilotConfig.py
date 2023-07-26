import os

from PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode, SparkSQLDataSourceEnum
import logging

# 配置日志记录器
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
pilot_logger = logging.getLogger("PilotScope")


class PilotConfig:

    def __init__(self, db_type: DatabaseEnum, db="stats", pilotscope_core_url="localhost", db_host="localhost") -> None:
        self.db_type: DatabaseEnum = db_type

        self.pilotscope_core_url = pilotscope_core_url
        self.data_fetch_method = DataFetchMethodEnum.HTTP
        self.db = db
        self.db_host = db_host

        # second
        self.sql_execution_timeout = 100
        self.once_request_timeout = self.sql_execution_timeout

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

    def print(self):
        for key, value in self.__dict__.items():
            print("{} = {}".format(key, value))

    def __str__(self):
        return self.__dict__.__str__()

    def set_db_type(self, db):
        self.db_type = db
        pass


class PostgreSQLConfig(PilotConfig):
    def __init__(self) -> None:
        super().__init__(db_type=DatabaseEnum.POSTGRESQL)
        # common config
        self.host = "localhost"
        self.user = "postgres"
        self.pwd = ""

        # for local postgres
        self.pg_ctl = "pg_ctl"
        self.pgdata = "~"
        self.db_config_path = "/var/lib/pgsql/13.1/data/postgresql.conf"
        self.backup_db_config_path = "postgresql-13.1.conf"


class SparkConfig(PilotConfig):
    def __init__(self, app_name, master_url) -> None:
        super().__init__(db_type=DatabaseEnum.SPARK)
        # spark
        self.app_name = app_name
        self.master_url = master_url

        # datasource
        self.datasource_type = None
        self.host = None
        self.db = None
        self.user = None
        self.pwd = None
        self.jdbc = "org.postgresql:postgresql:42.6.0"

        self.spark_configs = {}

        # spark config file path
        self.db_config_path = None
        self.backup_db_config_path = None

    def set_spark_session_config(self, config: dict):
        self.spark_configs.update(config)
        return self

    def set_datasource(self, datasource_type: SparkSQLDataSourceEnum, **datasource_conn_info):
        self.datasource_type = datasource_type
        if self.datasource_type == SparkSQLDataSourceEnum.POSTGRESQL:
            self.host = datasource_conn_info["host"]
            self.db = datasource_conn_info["db"]
            self.user = datasource_conn_info["user"]
            self.pwd = datasource_conn_info["pwd"]
            if "jdbc" in datasource_conn_info and datasource_conn_info["jdbc"] is not None:
                self.jdbc = datasource_conn_info["jdbc"]
        else:
            raise NotImplementedError("Unsupported datasource type: '{}'".format(self.datasource_type))
        return self

    def use_postgresql_datasource(self, datasource_type: SparkSQLDataSourceEnum, host, db, user, pwd):
        self.datasource_type = datasource_type
        jdbc = "org.postgresql:postgresql:42.6.0"
        self._use_dbms_datasource(host, db, user, pwd, jdbc)

    def _use_dbms_datasource(self, host, db, user, pwd, jdbc):
        self.host = host
        self.db = db
        self.user = user
        self.pwd = pwd
        self.jdbc = jdbc

    def set_knob_config(self, db_config_path, backup_db_config_path):
        self.db_config_path = db_config_path
        self.backup_db_config_path = backup_db_config_path
        return self
