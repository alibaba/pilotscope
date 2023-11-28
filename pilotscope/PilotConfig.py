import os

from pilotscope.Common.SSHConnector import SSHConnector
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

    def __init__(self, db_type: DatabaseEnum, db="stats_tiny", pilotscope_core_host="localhost", is_local=True) -> None:
        self.db_type: DatabaseEnum = db_type

        self.pilotscope_core_host = pilotscope_core_host
        self.data_fetch_method = DataFetchMethodEnum.HTTP
        self.db = db

        self.is_local = is_local

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
    def __init__(self, pilotscope_core_host="localhost", db_host="localhost", db_port="5432", db_user="postgres",
                 db_user_pwd="postgres") -> None:
        super().__init__(db_type=DatabaseEnum.POSTGRESQL, pilotscope_core_host=pilotscope_core_host)
        self.db_host = db_host
        self.db_port = db_port
        self.db_user = db_user
        self.db_user_pwd = db_user_pwd

        # for deep control
        self.pg_bin_path = None
        self.pgdata = None
        self.pg_ctl = None
        self.db_config_path = None
        self.backup_db_config_path = None
        self.db_host_user = None
        self.db_host_pwd = None
        self.db_host_port = None

    # def enable_deep_control(self, pg_bin_path, pgdata, db_host_user=None, db_host_pwd=None, db_host_ssh_port=54023):
    def enable_deep_control_local(self, pg_bin_path, pgdata):
        """Set value for local PostgreSQL. They influence the start, stop, changing config file, etc.
            If you do not need these functions, it is not necessary to set these values.
        :param pg_bin_path: the directory of binary file of postgresql, i.e. the path of 'postgres', 'pg_ctl' etc.
        :type pg_bin_path: str
        :param pgdata: location of the database storage area
        :type pgdata: str
        """

        self.pg_bin_path = pg_bin_path
        self.pgdata = pgdata
        self.backup_db_config_path = os.path.join(pgdata, "pilotscope_postgresql_backup.conf")
        self.db_config_path = os.path.join(pgdata, "postgresql.conf")
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")
        with open(self.db_config_path, "r") as f:
            with open(self.backup_db_config_path, "w") as w:
                w.write(f.read())
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")

    def enable_deep_control_remote(self, pg_bin_path, pgdata, db_host_user, db_host_pwd, db_host_ssh_port=22):
        """Set value for local PostgreSQL. They influence the start, stop, changing config file, etc.
            If you do not need these functions, it is not necessary to set these values.
        :param db_host_ssh_port:
        :param db_host_user:
        :param db_host_pwd:
        :param pg_bin_path: the directory of binary file of postgresql, i.e. the path of 'postgres', 'pg_ctl' etc.
        :type pg_bin_path: str
        :param pgdata: location of the database storage area
        :type pgdata: str
        """

        self.is_local = False
        self.db_host_user = db_host_user
        self.db_host_pwd = db_host_pwd
        self.db_host_port = db_host_ssh_port

        self.pg_bin_path = pg_bin_path
        self.pgdata = pgdata
        self.backup_db_config_path = os.path.join(pgdata, "pilotscope_postgresql_backup.conf")
        self.db_config_path = os.path.join(pgdata, "postgresql.conf")
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")

        ssh_conn = SSHConnector(self.db_host, self.db_host_user, self.db_host_pwd, self.db_host_port)
        ssh_conn.connect()
        with ssh_conn.open_file(self.db_config_path, "r") as f:
            with ssh_conn.open_file(self.backup_db_config_path, "w") as w:
                w.write(f.read())
        ssh_conn.close()
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")


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
