import os

from pilotscope.PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode, SparkSQLDataSourceEnum
import logging

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
pilot_logger = logging.getLogger("PilotScope")


class PilotConfig:
    """
    The PilotConfig class is used for storing and managing configuration information for PilotScope, including the host address of PilotScope, the name of the database to connect to, the user name and password to login to the database and etc.
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

    def set_db_type(self, db: DatabaseEnum):
        """Set database type.
        
        :arg PilotEnum db: now support ``pilotscope.PilotEnum.DatabaseEnum.POSTGRESQL`` and ``pilotscope.PilotEnum.DatabaseEnum.SPARK``
        """
        self.db_type = db

    def set_db(self, db):
        """Set the database name to connect to. 

        :param db: database name
        :type db: str
        """
        self.db = db

    def set_sql_execution_timeout(self, time):
        """Set the timeout for sql execution, which will pass to database adapter.

        :param time: sql execution timeout in second.
        :type time: int or float
        """
        self.sql_execution_timeout = float(time)

    def set_once_request_timeout(self, time):
        """Set the waiting time for fetching data. See ``pilotscope.DataFetchor.HttpDataFetcher``

        :param time: time in second
        :type time: int or float
        """
        self.once_request_timeout = float(time)

    def set_pilotscope_core_host(self, pilotscope_core_host):
        """Set the host that database sends extend result to. The value will add to the `prefixes`, whose key is "port" in json.

        :param pilotscope_core_host: A string representing the host or the IP address
        :type pilotscope_core_host: str
        """
        self.pilotscope_core_host = pilotscope_core_host

    def set_data_fetch_method(self, data_fetch_method: DataFetchMethodEnum):
        self.data_fetch_method = data_fetch_method

    def set_pretraining_model_mode(self, pretraining_model_mode: TrainSwitchMode):
        self.pretraining_model = pretraining_model_mode

    def print(self):
        for key, value in self.__dict__.items():
            print("{} = {}".format(key, value))


class PostgreSQLConfig(PilotConfig):
    def __init__(self) -> None:
        super().__init__(db_type=DatabaseEnum.POSTGRESQL)
        # common config
        self.host = "localhost"
        self.port = "5432"
        self.user = "postgres"
        self.pwd = ""

        # for local postgres
        self.pg_ctl = "pg_ctl"
        self.pgdata = "~"
        self.db_config_path = "/var/lib/pgsql/13.1/data/postgresql.conf"
        self.backup_db_config_path = "postgresql-13.1.conf"

    def set_postgresql_local_config(self, pg_ctl, pgdata, db_config_path, backup_db_config_path):
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

    def set_host(self, host="localhost"):
        """Set the database server host or socket directory of DBMS to connect to.

        :param host: A string representing the database server host or socket directory (default: "localhost")
        :type host: str
        """
        self.host = host

    def set_port(self, port="5432"):
        """Set the database server port to connect to. 

        :param port:  A string representing the database server port (default: "5432")
        :type port: str
        """
        self.port = port

    def set_user(self, user="postgres"):
        """Set the database user name 

        :param user: database user name (default: "postgres")
        :type user: str
        """
        self.user = user

    def set_password(self, pwd):
        """Set the password of the database user

        :param pwd: password string
        :type pwd: str
        """
        self.pwd = pwd


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
