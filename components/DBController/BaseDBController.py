import threading
from abc import ABC, abstractmethod

from pandas import DataFrame
from sqlalchemy import create_engine, String, Integer, Float, MetaData, Table, inspect
from sqlalchemy_utils import database_exists, create_database

from PilotConfig import PilotConfig
from common.Index import Index


class BaseDBController(ABC):
    def __init__(self, config, echo=True, allow_to_create_db=False):
        self.config = config
        self.allow_to_create_db = allow_to_create_db
        self.echo = echo
        self.connection_thread = threading.local()
        self._db_init()

    def _db_init(self):
        self.engine = self._create_engine()

        # update info of existed tables
        self.metadata = MetaData()
        self.metadata.reflect(self.engine)
        self.name_2_table = {}
        for table_name, table_info in self.metadata.tables.items():
            self.name_2_table[table_name] = table_info

        self.connect_if_loss()

    def _create_engine(self):
        conn_str = self._create_conn_str()
        if not database_exists(conn_str):
            create_database(conn_str, encoding="SQL_ASCII")

        return create_engine(conn_str, echo=self.echo, pool_size=10, pool_recycle=3600,
                             connect_args={
                                 "options": "-c statement_timeout={}".format(self.config.sql_execution_timeout * 1000)},
                             client_encoding='utf8', isolation_level="AUTOCOMMIT")

    def get_connection(self):
        return self.connection_thread.conn

    def connect_if_loss(self):
        if not self.is_connect():
            self.connection_thread.conn = self.engine.connect()
        pass

    def disconnect(self):
        if self.is_connect():
            self.connection_thread.conn.close()
            self.connection_thread.conn = None

    def is_connect(self):
        return hasattr(self.connection_thread, "conn") and self.connection_thread.conn is not None

    @abstractmethod
    def modify_sql_for_ignore_records(self, sql, is_execute):
        pass

    @abstractmethod
    def explain_physical_plan(self, sql):
        pass

    @abstractmethod
    def explain_logical_plan(self, sql):
        pass

    @abstractmethod
    def explain_execution_plan(self, sql):
        pass

    @abstractmethod
    def _create_conn_str(self):
        pass

    @abstractmethod
    def execute(self, sql, fetch=False):
        pass

    @abstractmethod
    def set_hint(self, key, value):
        raise NotImplementedError

    @abstractmethod
    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        pass

    @abstractmethod
    def insert(self, table_name, column_2_value: dict):
        pass

    @abstractmethod
    def get_table_row_count(self, table_name):
        pass

    @abstractmethod
    def exist_table(self, table_name) -> bool:
        pass

    @abstractmethod
    def create_index(self, index):
        pass

    @abstractmethod
    def create_index(self, index):
        pass

    @abstractmethod
    def drop_index(self, index_name):
        pass

    @abstractmethod
    def drop_all_indexes(self):
        pass

    @abstractmethod
    def get_all_indexes_byte(self):
        pass

    @abstractmethod
    def get_table_indexes_byte(self, table):
        pass

    @abstractmethod
    def get_index_byte(self, index_name):
        pass

    @abstractmethod
    def get_estimated_cost(self, sql):
        pass

    def _create_inspect(self):
        return inspect(self.engine)

    def get_index_number(self, table):
        inspector = self._create_inspect()
        n = len(inspector.get_indexes(table))
        return n

    def get_existed_index(self, table):
        inspector = self._create_inspect()
        db_indexes = inspector.get_indexes(table)

        indexes = []
        for db_index in db_indexes:
            indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_all_indexes(self):
        inspector = self._create_inspect()
        indexes = []
        for table in inspector.get_table_names():
            db_indexes = inspector.get_indexes(table)
            for db_index in db_indexes:
                indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_sqla_table(self, table_name):
        if table_name not in self.name_2_table:
            return None
        return self.name_2_table[table_name]

    def get_data(self, query):
        result = self.execute(query, fetch=True)
        return DataFrame(result)

    def update_data(self, query):
        self.execute(query)

    def shutdown(self):
        pass

    def start(self):
        pass

    def restart(self):
        self.shutdown()
        self.start()

    def write_knob_to_file(self, knobs):
        pass

    def recover_config(self):
        pass

    def _to_db_data_type(self, column_2_value):
        column_2_type = {}
        for col, data in column_2_value.items():
            data_type = String
            if type(data) == int:
                data_type = Integer
            elif type(data) == float:
                data_type = Float
            elif type(data) == str:
                data_type = String
            elif type(data) == dict:
                data_type = String
            elif type(data) == list:
                data_type = String
            column_2_type[col] = data_type
        return column_2_type
