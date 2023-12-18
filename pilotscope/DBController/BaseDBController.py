import threading
from abc import ABC, abstractmethod

from sqlalchemy import create_engine, String, Integer, Float, MetaData, Table, inspect, select, func, Column
from sqlalchemy_utils import database_exists, create_database

from pilotscope.Common.Index import Index
from pilotscope.Exception.Exception import DatabaseDeepControlException
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum


class BaseDBController(ABC):
    def __init__(self, config: PilotConfig, echo=True):
        """ 
        :param config: The config of PilotScope including the config of database.
        :param echo: if true, the more detailed information will be printed when executing the sql statement.
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
        self._connect_if_loss()

    def _create_engine(self):
        """
        Create the database engine.

        :return: The created database engine.
        """
        conn_str = self._create_conn_str()

        if not database_exists(conn_str):
            create_database(conn_str, encoding="utf8", template="template0")

        return create_engine(conn_str, echo=self.echo, pool_size=10, pool_recycle=3600,
                             connect_args={"options": "-c statement_timeout={}".format(
                                 self.config.sql_execution_timeout * 1000)}, client_encoding='utf8',
                             isolation_level="AUTOCOMMIT")

    def _get_connection(self):
        """
        Get the connection of DBController.

        :return: the connection object of sqlalchemy in thread-local data
        :rtype: Connection of sqlalchemy

        """
        return self.connection_thread.conn

    def _connect_if_loss(self):
        """
        If the connection is lost, establish a new connection to the database.

        """
        if not self._is_connect():
            self.connection_thread.conn = self.engine.connect()

    def _reset(self):
        """
        Reset the database connection.
        This function closes the current connection, recreates the pool, and establishes a new connection
        to the database.
        """
        if self.connection_thread.conn is not None:
            self.connection_thread.conn.invalidate()
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
        Get a physical plan from database's optimizer for a given SQL query.

        :param sql: The SQL query to be explained.
        """
        pass

    @abstractmethod
    def explain_execution_plan(self, sql):
        """
        Get an execution plan from database's optimizer for a given SQL query.

        :param sql: The SQL query to be explained.
        """
        pass

    @abstractmethod
    def _create_conn_str(self):
        pass

    @abstractmethod
    def execute(self, sql, fetch=False):
        """
        Execute a sql statement.

        :param sql: A SQL statement to be executed.
        :param fetch: fetch result or not. If True, the function will return a list of tuple representing the result of the sql.
        """
        pass

    @abstractmethod
    def set_hint(self, key, value):

        """
        Set the value of each hint (i.e., the run-time config) when execute SQL queries.
        The hints can be used to control the behavior of the database system in a session.

        For PostgreSQL, you can find all valid hints in https://www.postgresql.org/docs/13/runtime-config.html.

        For Spark, you can find all valid hints (called conf in Spark) in https://spark.apache.org/docs/latest/configuration.html#runtime-sql-configuration

        :param key: The key associated with the hint.
        :param value: The value of the hint to be set.
        """
        raise NotImplementedError

    @abstractmethod
    def create_index(self, index: Index):
        """
        Create an index on columns `index.columns` of table `index.table` with name `index.index_name`.

        :param index: a Index object including the information of the index
        """
        pass

    @abstractmethod
    def drop_index(self, index: Index):
        """
        Drop an index by its index name.

        :param index: an index that will be dropped
        """

    pass

    @abstractmethod
    def drop_all_indexes(self):
        """
        Drop all indexes across all tables in the database.
        This will not delete the system indexes and unique indexes.
        """
        pass

    @abstractmethod
    def get_all_indexes_byte(self):
        """
        Get the size of all indexes across all tables in the database in bytes.
        This will include the system indexes and unique indexes.

        :return: the size of all indexes in bytes
        """
        pass

    @abstractmethod
    def get_table_indexes_byte(self, table_name):
        """
        Get the size of all indexes on a table in bytes.
        This will include the system indexes and unique indexes.


        :param table_name: a table name that the indexes belong to
        :return: the size of all indexes on the table in bytes
        """
        pass

    @abstractmethod
    def get_index_byte(self, index: Index):
        """
        Get the size of an index in bytes by its index name.

        :param index: the index to get size
        :return: the size of the index in bytes
        """
        pass

    def get_index_number(self, table):
        """
        Get the number of indexes built on the specified table.

        :param table: name of the table
        :return: the number of index
        """
        inspector = self._create_inspect()
        n = len(inspector.get_indexes(table))
        return n

    def get_existed_indexes(self, table):
        """
        Retrieves the existing index on the specified table.
        This will not include the system indexes and unique indexes.

        :param table: the name of the table
        :return: a list of pilotscope.common.Index
        """
        inspector = self._create_inspect()
        db_indexes = inspector.get_indexes(table)

        indexes = []
        for db_index in db_indexes:
            indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_all_indexes(self):
        """
        Get all indexes across all tables in the database.

        :return: a list of pilotscope.common.Index
        """
        inspector = self._create_inspect()
        indexes = []
        for table in inspector.get_table_names():
            db_indexes = inspector.get_indexes(table)
            for db_index in db_indexes:
                indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def get_estimated_cost(self, sql, comment=""):
        """
        Get an estimated cost of a SQL query.

        :param sql: The SQL query for which to estimate the cost.
        :param comment: An optional comment to include with the query plan. Useful for debugging.
        :return: The estimated total cost of executing the SQL query.
        """
        pass

    def _create_inspect(self):
        return inspect(self.engine)

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        """
        Create a table according to parameters if absences. This function will not insert any data into the table.
        The column names and types of the table will be inferred from `column_2_value`.

        :param table_name: the name of the table you want to create
        :param column_2_value: a dict, whose keys are the names of columns and values. This data will be used to infer the column names and types of the table.
        :param primary_key_column: A column name in `column_2_value`. The corresponding column will be set as primary key. Otherwise, there will be no primary key.
        :param enable_autoincrement_id_key: If it is True, the `primary_key_column` will be autoincrement. It is only meaningful when `primary_key_column` is not None.
        """
        self._connect_if_loss()
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
        """
        if self.exist_table(table_name):
            table = Table(table_name, self.metadata, autoload_with=self.engine)
            table.drop(self.engine)
            self.metadata.remove(table)

    def exist_table(self, table_name) -> bool:
        """
        If the table named `table_name` exist or not

        :return: the table named `table_name` exist, it returns True; otherwise, it returns False
        """
        return self.engine.dialect.has_table(self._get_connection(), table_name)

    def get_all_table_names(self):
        """
        Retrieves a list of all table names in the database.

        :return: A list of table names present in the database.
        """
        self._update_sqla_tables()
        return list(self.metadata.tables.keys())

    def insert(self, table_name, column_2_value: dict):
        """
        Insert a new row into the table with each column's value set as column_2_value.

        :param table_name: the name of the table
        :param column_2_value: a dict where the keys are column names and the values are the values to be inserted
        """
        self._connect_if_loss()
        table = Table(table_name, self.metadata, autoload_with=self.engine)
        self.execute(table.insert().values(column_2_value))

    def get_table_columns(self, table_name):
        """
        Get all column names of a table

        :param table_name: the names of the table 
        :return: the list of the names of column
        """
        return [c.key for c in self._get_sqla_table(table_name).c]

    def get_table_row_count(self, table_name):
        """ 
        Get the row count of the table

        :param table_name: the name of the table 
        :return: the row count
        """
        table = self._get_sqla_table(table_name)
        stmt = select(func.count()).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]

    def get_column_max(self, table_name, column_name):
        """ 
        Get the maximum of a column

        :param table_name: the name of the table that the column belongs to
        :param column_name: the name of the column
        :return: the maximum, type of which is same as the data of the column
        """
        table = self._get_sqla_table(table_name)
        stmt = select(func.max(table.c[column_name])).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]

    def get_column_min(self, table_name, column_name):
        """   
        Get the minimum of a column

        :param table_name: the name of the table that the column belongs to
        :param column_name: the name of the column
        :return: the minimum, type of which is same as the data of the column
        """
        table = self._get_sqla_table(table_name)
        stmt = select(func.min(table.c[column_name])).select_from(table)
        result = self.execute(stmt, fetch=True)
        return result[0][0]

    def shutdown(self):
        """
        shutdown the database
        """
        pass

    def start(self):
        """
        start the database
        """
        pass

    def restart(self):
        """
        restart the database
        """
        if self.config.db_type != DatabaseEnum.SPARK:
            self._check_enable_deep_control()

        self.shutdown()
        self.start()

    def write_knob_to_file(self, key_2_value_knob):
        """
        Write knobs to config file, you should restart database to make it work.

        :param key_2_value_knob: a dict with keys as the names of the knobs and values as the values to be set.
        """
        pass

    def recover_config(self):
        """
        Recover config file of database to the lasted saved config file by `backup_config()`
        """
        pass

    def _to_db_data_type(self, column_2_value):
        """
        Converts Python data types to database data types.

        :param column_2_value: A dictionary mapping column names to their respective values, e.g. {'col1': 'value1', 'col2': 'value2'}
        :return: A dictionary mapping column names to SQLAlchemy data types.
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

    def _update_sqla_tables(self):
        """
        Retrieves a dictionary of all SQLAlchemy table objects reflected from the database.
        """
        self.metadata.reflect(self.engine)

    def _get_sqla_table(self, table_name):
        """
        Get SQLAlchemy `Table` object of a table

        :param table_name: the name of the table
        :return: the SQLAlchemy `Table` object of the table
        """
        # update info of existed tables
        return Table(table_name, self.metadata, autoload_with=self.engine)

    def _check_enable_deep_control(self):
        if not self.config._enable_deep_control:
            raise DatabaseDeepControlException()
