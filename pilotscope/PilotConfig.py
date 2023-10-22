import os

from pilotscope.PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode, SparkSQLDataSourceEnum
import logging

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
pilot_logger = logging.getLogger("PilotScope")


class PilotConfig:
    """
    The PilotConfig class is used for storing and managing configuration information for PilotScope,
    including the host address of PilotScope, the name of the database to connect to,
    the user name and password to log into the database, etc.
    """

    def __init__(self, db_type: DatabaseEnum, db="stats_tiny", pilotscope_core_host="localhost") -> None:
        self.db_type: DatabaseEnum = db_type

        self.pilotscope_core_host = pilotscope_core_host
        self.data_fetch_method = DataFetchMethodEnum.HTTP
        self.db = db

        # second
        self.sql_execution_timeout = 300
        self.once_request_timeout = self.sql_execution_timeout

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

    def __str__(self):
        return self.__dict__.__str__()

    def print(self):
        for key, value in self.__dict__.items():
            print("{} = {}".format(key, value))


class PostgreSQLConfig(PilotConfig):
    def __init__(self, host="localhost", port="5432", user="postgres", pwd="") -> None:
        super().__init__(db_type=DatabaseEnum.POSTGRESQL)
        self.host = host
        self.port = port
        self.user = user
        self.pwd = pwd

        # for local postgres
        self.pg_ctl = None
        self.pgdata = None
        self.db_config_path = None
        self.backup_db_config_path = None

    def set_knob_config(self, pg_ctl, pgdata, db_config_path, backup_db_config_path):
        """Set value for local PostgreSQL. They influence the start, stop, changing config file, etc. If you do not need these functions, it is not necessary to set these values.

        :param pg_ctl: the directory of pg_ctl
        :type pg_ctl: str
        :param pgdata: location of the database storage area
        :type pgdata: str
        :param db_config_path: location of the database config file
        :type db_config_path: str
        :param backup_db_config_path: location of the backup of the database config file, you could copy the default config file to anothor directory and fill the directory here.
        :type backup_db_config_path: str
        """
        self.pg_ctl = pg_ctl
        self.pgdata = pgdata
        self.db_config_path = db_config_path
        self.backup_db_config_path = backup_db_config_path


class SparkConfig(PilotConfig):
    def __init__(self, app_name, master_url) -> None:
        super().__init__(db_type=DatabaseEnum.SPARK)
        # spark
        self.app_name = app_name
        self.master_url = master_url

        # datasource
        self.datasource_type = None
        self.host = None
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

    def push_knob_config(self, db_config_path, backup_db_config_path):
        self.db_config_path = db_config_path
        self.backup_db_config_path = backup_db_config_path
        return self
