import threading
from abc import ABC, abstractmethod

from pandas import DataFrame
from sqlalchemy import create_engine, String, Integer, Float, MetaData, Table, inspect, select, func, Column
from sqlalchemy_utils import database_exists, create_database

from pilotscope.PilotConfig import PilotConfig
from pilotscope.common.Index import Index


class BaseDBController(ABC):    
    def __init__(self, config, echo=True, allow_to_create_db=False):
        """ 

        :param config: The database configuration information.
        :type config: pilotscope.PilotConfig
        :param echo: if True, the sqlachemy connection pool will log informational output such as when connections are invalidated as well as when connections are recycled to the default log handler, which defaults to sys.stdout for output. defaults to True
        :type echo: bool, optional
        :param allow_to_create_db: defaults to False
        :type allow_to_create_db: bool, optional
        """        
        self.config = config
        self.allow_to_create_db = allow_to_create_db
        self.echo = echo
        self.connection_thread = threading.local()
        self._db_init()

    def _db_init(self):
        self.engine = self._create_engine()
        
        self.metadata = MetaData()
        
        self.connect_if_loss()

    def _create_engine(self):
        conn_str = self._create_conn_str()
        if not database_exists(conn_str):
            create_database(conn_str, encoding="SQL_ASCII")

        return create_engine(conn_str, echo=self.echo, pool_size=10, pool_recycle=3600,
                             connect_args={
                                 "options": "-c statement_timeout={}".format(int(self.config.sql_execution_timeout * 1000))},
                             client_encoding='utf8', isolation_level="AUTOCOMMIT")

    def get_connection(self):
        """Get the connection of DBController

        :return: the connection object of sqlalchemy in thread-local data
        :rtype: ``Connection`` of sqlalchemy
        """        
        return self.connection_thread.conn

    def connect_if_loss(self):
        if not self.is_connect():
            self.connection_thread.conn = self.engine.connect()

    def reset(self):
        self.connection_thread.conn.close()
        self.engine.pool = self.engine.pool.recreate()
        self.connection_thread.conn = self.engine.connect()

    def disconnect(self):
        if self.is_connect():
            self.connection_thread.conn.close()
            self.connection_thread.conn = None

    def is_connect(self):
        """If self have connected, return True. Otherwise, return False. Note that if the DBMS is stopped from outside, the return value of this function will not change.

        :return: if self connected or not
        :rtype: bool
        """        
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

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        """Create a table according to parameters if absences

        :param table_name: the name of the table you want to create
        :type table_name: str
        :param column_2_value: a dict, whose keys is the names of columns and values repersent data type. The values is arbitrary, we only use the type of values. 
        :type column_2_value: dict
        :param primary_key_column: If ``primary_key_column`` is a string, the column named ``primary_key_column`` will be the primary key of the new table. If it is None, there will be no primary key.
        :type primary_key_column: str or None, optional
        :param enable_autoincrement_id_key: If it is True, the primary key will be autoincrement. It is only meaningful when primary_key_column is a string.
        :type enable_autoincrement_id_key: bool, optional
        """        
        if not self.exist_table(table_name):
            column_2_type = self._to_db_data_type(column_2_value)
            columns = []
            for column, column_type in column_2_type.items():
                if column == primary_key_column:
                    columns.append(
                        Column(column, column_type, primary_key=True, autoincrement=enable_autoincrement_id_key))
                else:
                    columns.append(Column(column, column_type))
            table = Table(table_name, self.metadata, *columns, extend_existing=True)
            table.create(self.engine)


    def drop_table_if_existence(self, table_name):
        """Try to drop table named ``table_name``

        :param table_name: the name of the table
        :type table_name: str
        """
        if self.exist_table(table_name):
            Table(table_name, self.metadata, autoload_with = self.engine).drop(self.engine)
        
    def exist_table(self, table_name) -> bool:
        """If the table named ``table_name`` exist or not

        :return: the the table named ``table_name`` exist, it is return True; otherwise, it is return False
        :rtype: bool
        """        
        return self.engine.dialect.has_table(self.get_connection(), table_name)
    
    def get_all_sqla_tables(self):
        self.metadata.reflect(self.engine)
        return self.metadata.tables
    
    def get_all_table_names(self):
        return list(self.get_all_sqla_tables().keys())
    
    def insert(self, table_name, column_2_value: dict):
        """Insert a new row into the table with each column's value set as column_2_value.

        :param table_name: the name of the table
        :type table_name: str
        :param column_2_value: a dict where the keys are column names and the values are the values to be inserted
        :type column_2_value: dict
        """        
        table = Table(table_name, self.metadata, autoload_with=self.engine)
        self.execute(table.insert().values(column_2_value))

    def get_table_column_name(self, table_name):
        """Get all column names of a table

        :param table_name: the names of the table 
        :type table_name: str
        :return: the list of the names of column
        :rtype: list
        """        
        return [c.key for c in self.get_sqla_table(table_name).c]
    
    def get_table_row_count(self, table_name):
        """Get the row count of the a table

        :param table_name: the name of the table 
        :type table_name: str
        :return: the row count
        :rtype: int
        """
        table = self.get_sqla_table(table_name)        
        stmt = select(func.count()).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]
    
    def get_column_max(self, table_name, column_name):
        """Get the maximum  of a column

        :param table_name: the name of the table that the column belongs to
        :type table_name: str
        :param column_name: the name of the column
        :type column_name: str
        :return: the maximum, type of which is same as the data of the column
        """
        table = self.get_sqla_table(table_name)
        stmt = select(func.max(table.c[column_name])).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]

    def get_column_min(self, table_name, column_name):
        """Get the minimum of a column

        :param table_name: the name of the table that the column belongs to
        :type table_name: str
        :param column_name: the name of the column
        :type column_name: str
        :return: the maximum, type of which is same as the data of the column
        """
        table = self.get_sqla_table(table_name)
        stmt = select(func.min(table.c[column_name])).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]
    
    def get_index_number(self, table):
        """Get the number of index in the table

        :param table: name of the table
        :type table: str
        :return: the number of index 
        :rtype: int
        """        
        inspector = self._create_inspect()
        n = len(inspector.get_indexes(table))
        return n

    def get_existed_index(self, table):
        """Get all indexes of a table

        :param table: the name of the table
        :type table: str
        :return: a list of pilotscope.common.Index
        :rtype: list
        """        
        inspector = self._create_inspect()
        db_indexes = inspector.get_indexes(table)

        indexes = []
        for db_index in db_indexes:
            indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_all_indexes(self):
        """Get all indexes of all table

        :return: a list of pilotscope.common.Index
        :rtype: list
        """        
        inspector = self._create_inspect()
        indexes = []
        for table in inspector.get_table_names():
            db_indexes = inspector.get_indexes(table)
            for db_index in db_indexes:
                indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_sqla_table(self, table_name):
        """Get sqlachemy ``Table`` object of a table

        :param table_name: the name of the table
        :type table_name: str
        :return: the sqlachemy ``Table`` object of the table
        :rtype: Table of sqlachemy
        """
        # update info of existed tables
        return Table(table_name, self.metadata, autoload_with=self.engine)

    def shutdown(self):
        # shutdown local database 
        pass

    def start(self):
        # start local database 
        pass

    def restart(self):
        # restart local database 
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
