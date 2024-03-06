import os
import json
from pilotscope.Common.SSHConnector import SSHConnector
from pilotscope.PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode, SparkSQLDataSourceEnum
import logging

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
pilot_logger = logging.getLogger("PilotScope")


class PilotConfig:
    """
    The PilotConfig class is used for storing and managing configuration information for PilotScope,
    including the host address of PilotScope, the name of the database to connect to,
    the username and password to log into the database, etc.
    """

    def __init__(self, db_type: DatabaseEnum, db="stats_tiny", pilotscope_core_host="localhost",
                 user_data_db_name="PilotScopeUserData", sql_execution_timeout=300, once_request_timeout=300) -> None:
        """
        Initialize the PilotConfig.

        :param db_type: the type of database, i.e. PostgreSQL, SparkSQL, etc.
        :param db: the name of connected database
        :param pilotscope_core_host: the host address of PilotScope in ML side.
        :param user_data_db_name: the created database name for saving the user data. If users want to visit these data, they can set db=user_data_db_name.
        :param sql_execution_timeout: the timeout of sql execution, unit: second
        :param once_request_timeout: the timeout of once request, unit: second
        """

        self.db_type: DatabaseEnum = db_type

        self.pilotscope_core_host = pilotscope_core_host
        self.data_fetch_method = DataFetchMethodEnum.HTTP
        self.db = db
        self.user_data_db_name = user_data_db_name

        self._enable_deep_control = False
        self._is_local = True
        self.sql_execution_timeout = sql_execution_timeout
        self.once_request_timeout = once_request_timeout

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

    def __str__(self):
        return self.__dict__.__str__()

    def print(self):
        """
        Print the configuration information of PilotScope.
        """
        for key, value in self.__dict__.items():
            print("{} = {}".format(key, value))


class PostgreSQLConfig(PilotConfig):
    def __init__(self, pilotscope_core_host = None, db_host = None, db_port = None, db_user= None,
                 db_user_pwd = None, db = None, sql_execution_timeout = None,once_request_timeout = None) -> None:
        """
        :param pilotscope_core_host: the host address of PilotScope in ML side.
        :param db_host: the host address of database
        :param db_port: the port of database
        :param db_user: the username to log into the database
        :param db_user_pwd: the password to log into the database
        """
        super().__init__(db_type=DatabaseEnum.POSTGRESQL, db = db, pilotscope_core_host = pilotscope_core_host,\
                         sql_execution_timeout = sql_execution_timeout, once_request_timeout = once_request_timeout)
        self.db_host = db_host
        self.db_port = db_port
        self.db_user = db_user
        self.db_user_pwd = db_user_pwd
        with open(os.path.join(os.path.dirname(__file__), "pilotscope_conf.json"), "r") as f:
            d = json.load(f)["PostgreSQLConfig"]
        for k, v in d.items():
            if getattr(self, k) is None:
                setattr(self, k, v)
        # for deep control
        self.pg_bin_path = None
        self.pgdata = None
        self.pg_ctl = None
        self.db_config_path = None
        self.backup_db_config_path = None
        self.db_host_user = None
        self.db_host_pwd = None
        self.db_host_port = None

    def enable_deep_control_local(self, pg_bin_path: str = None, pg_data_path: str = None):
        """
        Enable deep control for PostgreSQL, such as  starting and stopping database, changing config file, etc.
        If you do not need these functions, it is not necessary to set these values.
        If the database and PilotScope Core are on the same machine, you can use this function, i.e., pilotscope_core_host != db_host.
        Otherwise, use `enable_deep_control_remote`
        
        :param pg_bin_path: the directory of binary file of postgresql, e.g., /postgres_install_path/bin
        :param pg_data_path: location of the database data storage
        :param db_host_user: the username to log into the database host
        :param db_host_pwd: the password to log into the database host
        """
        if pg_bin_path is None or pg_data_path is None:
            with open(os.path.join(os.path.dirname(__file__), "pilotscope_conf.json"), "r") as f:
                d = json.load(f)["PostgreSQLConfig_enable_deep_control_local"]
                if pg_bin_path is None:
                    pg_bin_path = d["pg_bin_path"]
                if pg_data_path is None:
                    pg_data_path = d["pg_data_path"]
        self._enable_deep_control = True
        self.pg_bin_path = pg_bin_path
        self.pgdata = pg_data_path
        self.backup_db_config_path = os.path.join(pg_data_path, "pilotscope_postgresql_backup.conf")
        self.db_config_path = os.path.join(pg_data_path, "postgresql.conf")
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")
        with open(self.db_config_path, "r") as f:
            with open(self.backup_db_config_path, "w") as w:
                w.write(f.read())
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")

    def enable_deep_control_remote(self, pg_bin_path = None, pg_data_path = None, db_host_user = None, db_host_pwd = None, db_host_ssh_port = None):
        """
        Enable deep control for PostgreSQL, such as starting and stopping database, changing config file, etc.
        If you do not need these functions, it is not necessary to set these values.
        If the database and PilotScope Core are not on the same machine, you can use this function, i.e., pilotscope_core_host != db_host.
        Otherwise, use `enable_deep_control_local`

        :param pg_bin_path:  the directory of binary file of postgresql, e.g., /postgres_install_path/bin
        :param pg_data_path: location of the database data storage
        :param db_host_user: the username to log into the database host
        :param db_host_pwd: the password to log into the database host
        :param db_host_ssh_port: the port of ssh service on the database host
        """
        if pg_bin_path is None or pg_data_path is None or db_host_user is None or db_host_pwd is None or db_host_ssh_port is None:
            with open(os.path.join(os.path.dirname(__file__), "pilotscope_conf.json"), "r") as f:
                d = json.load(f)["PostgreSQLConfig_enable_deep_control_local"]
            if pg_bin_path is None:
                pg_bin_path = d["pg_bin_path"]
            if pg_data_path is None:
                pg_data_path = d["pg_data_path"]
            if db_host_user is None:
                db_host_user = d["db_host_user"]
            if db_host_pwd is None:
                db_host_pwd is d["db_host_pwd"]
            if db_host_ssh_port is None:
                db_host_ssh_port = d["db_host_ssh_port"]
        self._is_local = False
        self._enable_deep_control = True

        self.db_host_user = db_host_user
        self.db_host_pwd = db_host_pwd
        self.db_host_port = db_host_ssh_port

        self.pg_bin_path = pg_bin_path
        self.pgdata = pg_data_path
        self.backup_db_config_path = os.path.join(pg_data_path, "pilotscope_postgresql_backup.conf")
        self.db_config_path = os.path.join(pg_data_path, "postgresql.conf")
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")

        ssh_conn = SSHConnector(self.db_host, self.db_host_user, self.db_host_pwd, self.db_host_port)
        ssh_conn.connect()
        with ssh_conn.open_file(self.db_config_path, "r") as f:
            with ssh_conn.open_file(self.backup_db_config_path, "w") as w:
                w.write(f.read())
        ssh_conn.close()
        self.pg_ctl = os.path.join(pg_bin_path, "pg_ctl")


class SparkConfig(PilotConfig):
    def __init__(self, pilotscope_core_host = None, app_name = None, master_url = None, db = None, sql_execution_timeout = None, once_request_timeout = None) -> None:
        """
        :param app_name: the name of the application of Spark
        :param master_url: the master URL of Spark cluster
        """

        super().__init__(db_type=DatabaseEnum.SPARK, db = db, pilotscope_core_host = pilotscope_core_host,\
                         sql_execution_timeout = sql_execution_timeout, once_request_timeout = once_request_timeout)
        # spark
        self.app_name = app_name
        self.master_url = master_url
        with open(os.path.join(os.path.dirname(__file__), "pilotscope_conf.json"), "r") as f:
            d = json.load(f)["SparkConfig"]
        for k, v in d.items():
            if getattr(self, k) is None:
                setattr(self, k, v)
        if self.master_url != "local[*]":
            raise NotImplementedError(
                "PilotScope only support master_url=local[*]. The more functionalities is developing")

        # postgresql datasource
        self.datasource_type = None
        self.db_host = None
        self.db_port = None
        self.db_user = None
        self.db_user_pwd = None
        self.jdbc = "org.postgresql:postgresql:42.6.0"

        self.spark_configs = {}

        self.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True
        })

    def set_spark_session_config(self, config: dict):
        self.spark_configs.update(config)
        return self

    def enable_cardinality_estimation(self):
        """
        Spark SQL support cost-based optimization but it is disabled by default.
        If you need to enable `pull_subquery_card` and `push_card`, please call this function, and PilotScope will set the corresponding parameters.
        This will consume more time, but the performance of the SQL will be better.
        """
        self.set_spark_session_config({
            "spark.sql.cbo.enabled": True,
            "spark.sql.cbo.joinReorder.enabled": True
        })

    def use_postgresql_datasource(self, db_host="localhost", db_port="5432", db_user="postgres",
                                  db_user_pwd="postgres", db="stats_tiny"):
        """
        Set up a PostgreSQL data source.

        :param db_host: the host of postgresql, defaults to "localhost"
        :param db_port: the network port of postgresql, defaults to "5432"
        :param db_user: the username to log into postgresql, defaults to "postgres"
        :param db_user_pwd: the password of the user, defaults to "postgres"
        :param db: database name, defaults to "stats_tiny"
        """
        self.datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
        self.db_host = db_host
        self.db_port = db_port
        self.db = db
        self.db_user = db_user
        self.db_user_pwd = db_user_pwd

if __name__=="__main__":
    conf = SparkConfig()
    conf.print()
