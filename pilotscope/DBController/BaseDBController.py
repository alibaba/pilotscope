import threading
from abc import ABC, abstractmethod

from sqlalchemy import create_engine, String, Integer, Float, MetaData, Table, inspect, select, func, Column
from sqlalchemy_utils import database_exists, create_database

from pilotscope.Common.Index import Index
from pilotscope.PilotConfig import PilotConfig


class BaseDBController(ABC):
    def __init__(self, config: PilotConfig, echo=True):
        """ 
        :param config: The database configuration information.
        :type config: pilotscope.PilotConfig
        :param echo: if True, the sqlachemy connection pool will log informational output such as when connections are invalidated as well as when connections are recycled to the default log handler, which defaults to sys.stdout for output. defaults to True
        :type echo: bool, optional
        """
        self.config = config
        self.echo = echo
        self.connection_thread = threading.local()
        self._db_init()

    def _db_init(self):
        """
        Initialize the database connection and engine.
        """
        self.engine = self._create_engine()
        self.metadata = MetaData()
        self.connect_if_loss()

    def _create_engine(self):
        """
        Create the database engine.

        :return: The created database engine.
        """
        conn_str = self._create_conn_str()

        if not database_exists(conn_str):
            create_database(conn_str, encoding="utf8", template="template0")

        # return create_engine(conn_str, echo=self.echo, pool_size=10, pool_recycle=3600,
        #                      connect_args={
        #                          "options": "-c statement_timeout={},'connect_timeout': {}".format(
        #                              # int(self.config.sql_execution_timeout * 1000))},
        #                              1, 2)},
        #                      client_encoding='utf8', isolation_level="AUTOCOMMIT")
        return create_engine(conn_str, echo=self.echo, pool_size=10, pool_recycle=3600,
                             client_encoding='utf8', isolation_level="AUTOCOMMIT")

    def _get_connection(self):
        """
        
        Get the connection of DBController

        :return: the connection object of sqlalchemy in thread-local data
        :rtype: Connection of sqlalchemy

        """
        return self.connection_thread.conn

    def connect_if_loss(self):
        """
        If the connection is lost, establish a new connection to the database.

        """
        if not self._is_connect():
            self.connection_thread.conn = self.engine.connect()

    def reset(self):
        """
        Reset the database connection.
        This function closes the current connection, recreates the pool, and establishes a new connection
        to the database.
        """
        self.connection_thread.conn.close()
        self.engine.pool = self.engine.pool.recreate()
        self.connection_thread.conn = self.engine.connect()

    def _disconnect(self):
        """
        Disconnect from the database.
        This function closes the connection if it is already established.
        """
        if self._is_connect():
            self.connection_thread.conn.close()
            self.connection_thread.conn = None

    def _is_connect(self):
        """
        
        If self have connected, return True. Otherwise, return False. Note that if the DBMS is stopped from outside, the return value of this function will not change.

        :return: if self connected or not
        :rtype: bool

        """
        return hasattr(self.connection_thread, "conn") and self.connection_thread.conn is not None

    @abstractmethod
    def explain_physical_plan(self, sql):
        """
        Generates an explanation of the physical plan for a given SQL query.

        :param sql: The SQL query string to be explained.
        :type sql: str
        """
        pass

    @abstractmethod
    def explain_execution_plan(self, sql):
        """
        Generates an explanation of the execution plan for a given SQL query.

        :param sql: The SQL query string for which the execution plan should be explained.
        :type sql: str
        """

        pass

    @abstractmethod
    def _create_conn_str(self):
        pass

    @abstractmethod
    def execute(self, sql, fetch=False):
        """
        Execute a sql statement

        :param sql: sql or extended sql
        :type sql: str
        :param fetch: fetch result or not. If True, the function will return a list of tuple representing the result of the sql.
        :type fetch: bool, optional
        """
        pass

    @abstractmethod
    def set_hint(self, key, value):

        """
        Sets a hint for a certain functionality within the class.

        :param key: The key associated with the hint.
        :type key: str
        :param value: The value of the hint to be set.
        :type value: str

        :raises NotImplementedError: If the method is not overridden in a subclass.
        """
        raise NotImplementedError

    @abstractmethod
    def create_index(self, index):
        """
        Creates an index in the database.

        :param index: The description or parameters of the index to be created.
        :type index: pilotscope.common.Index
        """
        pass

    @abstractmethod
    def drop_index(self, index_name):
        """
        Drops a specified index from the database.

        :param index_name: The name of the index to be dropped.
        :type index_name: pilotscope.common.Index
        """
        pass

    @abstractmethod
    def drop_all_indexes(self):
        """
        Drops all indexes from the database.
        of queries.
        """
        pass

    @abstractmethod
    def get_all_indexes_byte(self):
        """
        If using hypothesis index, i.e., self.enable_simulate_index is True, get the expected size in bytes of all hypothesis indexes; otherwise, return the actual size of the indexes in bytes.
        """
        pass

    @abstractmethod
    def get_table_indexes_byte(self, table):
        """
        If using hypothesis index, i.e., self.enable_simulate_index is True, return the expected size in bytes of all hypothesis indexes of the table; otherwise, return the actual size of the indexes of the table in bytes.
        
        :param str table: the name of the table
        """
        pass

    @abstractmethod
    def get_index_byte(self, index_name):
        """
        If using hypothesis index, i.e., self.enable_simulate_index is True, return the expected size in bytes of the index otherwise, return the actual size of the index in bytes.

        :param index: an index object
        :type index: pilotscope.common.Index
        """
        pass

    def get_estimated_cost(self, sql):
        """
        Estimates the cost of executing a given SQL query.

        :param sql: The SQL query string for which to estimate the cost.
        :type sql: str
        """
        pass

    def _create_inspect(self):
        return inspect(self.engine)

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        """
        Create a table according to parameters if absences

        :param table_name: the name of the table you want to create
        :type table_name: str
        :param column_2_value: a dict, whose keys is the names of columns and values represent data type, e.g. {"id": "int", "name": "varchar(20)"}
        :type column_2_value: dict
        :param primary_key_column: If `primary_key_column` is a string, the column named `primary_key_column` will be the primary key of the new table. If it is None, there will be no primary key.
        :type primary_key_column: str or None, optional
        :param enable_autoincrement_id_key: If it is True, the primary key will be autoincrement. It is only meaningful when primary_key_column is a string.
        :type enable_autoincrement_id_key: bool, optional
        """
        self.connect_if_loss()
        if primary_key_column is not None and primary_key_column not in column_2_value:
            raise RuntimeError("the primary key column {} is not in column_2_value".format(primary_key_column))

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

    def drop_table_if_exist(self, table_name):
        """
        Try to drop table named `table_name`

        :param table_name: the name of the table
        :type table_name: str

        """
        if self.exist_table(table_name):
            Table(table_name, self.metadata, autoload_with=self.engine).drop(self.engine)

    def exist_table(self, table_name) -> bool:
        """
        If the table named `table_name` exist or not

        :return: the the table named `table_name` exist, it is return True; otherwise, it is return False
        :rtype: bool
        """
        return self.engine.dialect.has_table(self._get_connection(), table_name)

    def get_all_sqla_tables(self):
        """
        Retrieves a dictionary of all SQLAlchemy table objects reflected from the database.

        :return: A dictionary of reflected SQLAlchemy Table objects.
        :rtype: dict
        """
        self.metadata.reflect(self.engine)
        return self.metadata.tables

    def get_all_table_names(self):
        """
        Retrieves a list of all table names in the database.

        :return: A list of table names present in the database.
        :rtype: list
        """
        return list(self.get_all_sqla_tables().keys())

    def insert(self, table_name, column_2_value: dict):
        """
        Insert a new row into the table with each column's value set as column_2_value.

        :param table_name: the name of the table
        :type table_name: str
        :param column_2_value: a dict where the keys are column names and the values are the values to be inserted
        :type column_2_value: dict
        """
        self.connect_if_loss()
        table = Table(table_name, self.metadata, autoload_with=self.engine)
        self.execute(table.insert().values(column_2_value))

    def get_table_column_name(self, table_name):
        """
        Get all column names of a table

        :param table_name: the names of the table 
        :type table_name: str
        :return: the list of the names of column
        :rtype: list
        """
        return [c.key for c in self.get_sqla_table(table_name).c]

    def get_table_row_count(self, table_name):
        """ 
        Get the row count of the a table

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
        """ 
        Get the maximum  of a column

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
        """   
        Get the minimum of a column

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
        """   
        Get the number of index in the table

        :param table: name of the table
        :type table: str

        :return: the number of index 
        :rtype: int
        """
        inspector = self._create_inspect()
        n = len(inspector.get_indexes(table))
        return n

    def get_existed_index(self, table):
        """ 
        Get all indexes of a table

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
        """
        Get all indexes of all table

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
        """ 
        Get sqlachemy `Table` object of a table

        :param table_name: the name of the table
        :type table_name: str
        
        :return: the sqlachemy `Table` object of the table
        :rtype: Table of sqlachemy
        """
        # update info of existed tables
        return Table(table_name, self.metadata, autoload_with=self.engine)

    def shutdown(self):
        """
        shutdown local database 
        """
        pass

    def start(self):
        """
        start local database
        """
        pass

    def restart(self):
        """
        restart local database
        """
        self.shutdown()
        self.start()

    def write_knob_to_file(self, knobs):
        """
        Write knobs to config file

        :param knobs: a dict with keys as the names of the knobs and values as the values to be set.
        :type knobs: dict
        """
        pass

    def recover_config(self):
        """
        Recover config file to the file at self.config.backup_db_config_path.
        """
        pass

    def _to_db_data_type(self, column_2_value):
        """
        Converts Python data types to database data types.

        :param column_2_value: A dictionary mapping column names to their respective values, e.g. {'col1': 'value1', 'col2': 'value2'}
        :type column_2_value: dict

        :return: A dictionary mapping column names to SQLAlchemy data types.
        :rtype: dict
        """
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
