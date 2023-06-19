from abc import ABC, abstractmethod
from pandas import DataFrame
from sqlalchemy import create_engine, String, Integer, Float, MetaData, Table
from sqlalchemy_utils import database_exists, create_database
from PilotSysConfig import PilotSysConfig


class BaseDBController(ABC):
    def __init__(self, config, echo=False, allow_to_create_db=False):
        self.config = config
        self.allow_to_create_db = allow_to_create_db

        self.echo = echo
        self.conn_str = self._create_conn_str()
        self.engine = self._create_engine()

        # update info of existed tables
        self.metadata = MetaData()
        self.metadata.reflect(self.engine)
        self.name_2_table = {}
        for table_name, table_info in self.metadata.tables.items():
            self.name_2_table[table_name] = table_info

    def _create_engine(self):
        if not database_exists(self.conn_str):
            create_database(self.conn_str, encoding="SQL_ASCII")
        return create_engine(self.conn_str, echo=self.echo, pool_size=1, pool_recycle=3600,
                             pool_pre_ping=True)

    @abstractmethod
    def explain_physical_plan(self, sql):
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
    def get_hint_sql(self, key, value):
        pass

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

    def get_sqla_table(self, table_name) -> Table:
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
