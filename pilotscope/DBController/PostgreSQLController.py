import os
from abc import ABC

from sqlalchemy import Table, Column, text, inspect
from sqlalchemy.exc import OperationalError
from typing_extensions import deprecated

from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Exception.Exception import DBStatementTimeoutException, DatabaseCrashException, DatabaseStartException
from pilotscope.common.Index import Index


class PostgreSQLController(BaseDBController):
    instances = set()

    def __new__(cls, *args, **kwargs):
        instance = super().__new__(cls)
        cls.instances.add(instance)
        return instance

    def __del__(self):
        self.disconnect()
        type(self).instances.remove(self)

    def __init__(self, config, echo=False, allow_to_create_db=False, enable_simulate_index=False):
        super().__init__(config, echo, allow_to_create_db)
        self.config: PostgreSQLConfig = config

        self.simulate_index_controller = None

        self.enable_simulate_index = enable_simulate_index
        if self.enable_simulate_index:
            self.simulate_index_visitor = SimulateIndexVisitor(self)
        self._add_extension()
        pass

    def _add_extension(self):
        extensions = self.get_available_extensions()
        if "pg_buffercache" not in extensions:
            self.execute("create extension pg_buffercache")
        if "pilotscope" not in extensions:
            self.execute("create extension pilotscope")
        if self.enable_simulate_index and "hypopg" not in extensions:
            self.execute("create extension hypopg")

    def get_available_extensions(self):
        """Get all extensions that have installed in the connected database

        :return: the list of extension names
        :rtype: list
        """        
        sql = ("SELECT name, default_version, installed_version FROM"
               " pg_available_extensions WHERE installed_version is not NULL ORDER BY name;")
        res = self.execute(sql, fetch=True)
        extensions = []
        for row in res:
            extensions.append(row[0])
        return extensions

    def _create_conn_str(self):
        # default postgresql://postgres@localhost:5432/stats
        return "{}://{}@{}:{}/{}".format("postgresql", self.config.user, self.config.host, self.config.port ,self.config.db)

    def execute(self, sql, fetch=False, fetch_column_name=False):
        """Execute a sql statement

        :param sql: sql or extended sql
        :type sql: str
        :param fetch: fetch result or not. If True, the function will return a list of tuple representing the result of the sql.
        :type fetch: bool, optional
        :param fetch_column_name: fetch the column names of the sql or not. If True, the first item of the result will be a tuple of column names. The parameter only makes sense when parameter ``fetch`` is True.
        :type fetch_column_name: bool, optional
        :raises DBStatementTimeoutException: the time of execution exceeded ``self.config.sql_execution_timeout``
        :return: If ``fetch`` is True, the function will return a list of tuple representing the result of the sql. Otherwise, it will return None
        :rtype: list or None
        """        
        row = None
        try:
            self.connect_if_loss()
            conn = self.get_connection()
            # res = conn.execute(text("select pg_backend_pid();")).all()[0][0]
            # with open(str(res)+".txt", "a") as f:
            #     f.write(str(sql))
            result = conn.execute(text(sql) if isinstance(sql, str) else sql)
            if fetch:
                row = result.all()
                if fetch_column_name:
                    row = [tuple(result.keys()), *row]
        except OperationalError as e:
            if "canceling statement due to statement timeout" in str(e):
                raise DBStatementTimeoutException(str(e))
            else:
                raise e
        except Exception as e:
            if "PilotScopeFetchEnd" not in str(e):
                raise e
        return row

    def set_hint(self, key, value):
        """Set hint in the connection the controller has

        :param key: the name of the hint
        :type key: str
        :param value: the value set to
        :type value: str
        """        
        sql = "SET {} TO {}".format(key, value)
        self.execute(sql)

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
        column_2_type = self._to_db_data_type(column_2_value)
        metadata_obj = self.metadata
        if not self.exist_table(table_name):
            columns = []
            for column, column_type in column_2_type.items():
                if column == primary_key_column:
                    columns.append(
                        Column(column, column_type, primary_key=True, autoincrement=enable_autoincrement_id_key))
                else:
                    columns.append(Column(column, column_type))
            table = Table(table_name, metadata_obj, *columns)
            table.create(self.engine)
            self.name_2_table[table_name] = table
    
    def drop_table_if_existence(self, table_name):
        """Try to drop table named ``table_name``

        :param table_name: the name of the table
        :type table_name: str
        """        
        if table_name in self.name_2_table:
            self.name_2_table[table_name].drop(self.engine)
            del self.name_2_table[table_name]

    def insert(self, table_name, column_2_value: dict):
        """Insert a new row into the table with each column's value set as column_2_value.

        :param table_name: the name of the table
        :type table_name: str
        :param column_2_value: a dict where the keys are column names and the values are the values to be inserted
        :type column_2_value: dict
        """        
        table = self.name_2_table[table_name]
        self.execute(table.insert().values(column_2_value))

    def create_index(self, index: Index):
        """
        :param index: a index object
        :type index: pilotscope.common.Index
        """        
        if self.enable_simulate_index:
            self.simulate_index_visitor.create_index(index)
        else:
            column_names = index.joined_column_names()
            sql = f"create index {index.index_name} on {index.table} ({column_names});"
            self.execute(sql, fetch=False)

    def drop_index(self, index):
        """
        :param index: an index object
        :type index: pilotscope.common.Index
        """   
        if self.enable_simulate_index:
            self.simulate_index_visitor.drop_index(index)
        else:
            statement = (
                f"DROP INDEX IF EXISTS {index.index_name};"
            )
            self.execute(statement, fetch=False)

    def drop_all_indexes(self):
        if self.enable_simulate_index:
            self.simulate_index_visitor.drop_all_indexes()
        else:
            indexes = self.get_all_indexes()
            for index in indexes:
                self.drop_index(index)

    def get_all_indexes_byte(self):
        """If using hypothesis index, i.e., self.enable_simulate_index is True, return the expected size in bytes of all hypothesis indexes; otherwise, return the actual size of the indexes in bytes.

        :return: size of indexes in bytes
        :rtype: float
        """        
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_all_indexes_byte()
        else:
            # Returns size in bytes
            sql = ("select sum(pg_indexes_size(table_name::text)) from "
                   "(select table_name from information_schema.tables "
                   "where table_schema='public') as all_tables;")
            result = self.execute(sql, fetch=True)
            return float(result[0][0])

    def get_table_indexes_byte(self, table):
        """If using hypothesis index, i.e., self.enable_simulate_index is True, return the expected size in bytes of all hypothesis indexes of the table; otherwise, return the actual size of the indexes of the table in bytes.
        :param str table: the name of the table
        :return: size of indexes in bytes
        :rtype: float
        """        
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(table)
        else:
            # Returns size in bytes
            sql = f"select pg_indexes_size('{table}');"
            result = self.execute(sql, fetch=True)
            return float(result[0][0])

    def get_index_byte(self, index: Index):
        """If using hypothesis index, i.e., self.enable_simulate_index is True, return the expected size in bytes of the index otherwise, return the actual size of the index in bytes.

        :param index: an index object
        :type index: pilotscope.common.Index
        :return: size of the index in bytes
        :rtype: float
        """        
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(index)
        else:
            sql = f"select pg_table_size('{index.get_index_name()}');"
            result = self.execute(sql, fetch=True)
            return int(result[0][0])

    def exist_table(self, table_name) -> bool:
        """If the table named ``table_name`` exist or not

        :return: the the table named ``table_name`` exist, it is return True; otherwise, it is return False
        :rtype: bool
        """        
        has_table = self.engine.dialect.has_table(self.get_connection(), table_name)
        if has_table:
            return True
        return False

    def modify_sql_for_ignore_records(self, sql, is_execute):
        return self.get_explain_sql(sql, is_execute)

    def explain_physical_plan(self, sql, comment=""):
        return self._explain(sql, comment, False)

    def explain_logical_plan(self, sql, comment=""):
        return self.explain_physical_plan(sql, comment)

    def explain_execution_plan(self, sql, comment=""):
        return self._explain(sql, comment, True)

    def get_estimated_cost(self, sql):
        plan = self.explain_physical_plan(sql)
        return plan["Plan"]["Total Cost"]

    def get_explain_sql(self, sql, execute: bool, comment=""):
        # the simulate index will be disabled if there are ANALYZE even though it is false
        return "{} explain ({} VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
                                                                                   "ANALYZE," if execute else "",
                                                                                   sql)

    def get_buffercache(self):
        """Get the numbers of buffer per table in the shared buffer cache in real time.

        :return: a dict, of which keys are the names of table and values are the numbers of buffer per table
        :rtype: dict (str: int)
        """        
        sql = """
            SELECT c.relname, count(*) AS buffers
            FROM pg_buffercache b JOIN pg_class c
            ON b.relfilenode = pg_relation_filenode(c.oid) AND
            b.reldatabase IN (0, (SELECT oid FROM pg_database
                                    WHERE datname = current_database()))
            JOIN pg_namespace n ON n.oid = c.relnamespace
            GROUP BY c.relname;
            """
        res = self.execute(sql, fetch=True)
        return {k: v for k, v in res if not k.startswith("pg_")}

    def _explain(self, sql, comment, execute: bool):
        return self.execute(text(self.get_explain_sql(sql, execute, comment)), True)[0][0][0]

    # switch user and run
    def _surun(self, cmd):
        return os.system("su {} -c '{}'".format(self.config.user, cmd))

    def shutdown(self):
        """Shutdown the local DBMS
        """        
        for instance in type(self).instances:
            # if hasattr(instance, "engine"):
            instance.disconnect() # to set DBController's self.connection_thread.conn is None
            instance.engine.dispose(close = True)
            # del instance.engine
        self._surun("{} stop -D {}".format(self.config.pg_ctl, self.config.pgdata))

    def start(self):
        """Try to start DBMS. If fails the first time, recover config to ``self.config.backup_db_config_path`` and raise ``DatabaseStartException``. If fails again after recovering config, raise DatabaseCrashException.

        :raises DatabaseStartException:
        :raises DatabaseCrashException:
        """        
        res = self._surun("{} start -D {}".format(self.config.pg_ctl, self.config.pgdata))
        if res != 0: 
            self.recover_config()
            res = self._surun("{} start -D {}".format(self.config.pg_ctl, self.config.pgdata))
            if res == 0:
                raise DatabaseStartException
            else:
                raise DatabaseCrashException
        for instance in type(self).instances:
            instance.connect_if_loss()

    def status(self):
        res = os.popen("su {} -c '{} status -D {}'".format(self.config.user, self.config.pg_ctl, self.config.pgdata))
        return res.read()

    def write_knob_to_file(self, knobs: dict):
        """Write knobs to config file

        :param knobs: a dict with keys as the names of the knobs and values as the values to be set.
        :type knobs: dict
        """               
        with open(self.config.db_config_path, "a") as f:
            f.write("\n")
            for k, v in knobs.items():
                f.write("{} = {}\n".format(k, v))

    def recover_config(self):
        """Recover config file to the file at ``self.config.backup_db_config_path``
        """        
        with open(self.config.backup_db_config_path, "r") as f:
            db_config_file = f.read()
        with open(self.config.db_config_path, "w") as f:
            f.write(db_config_file)

    def get_table_column_name(self, table_name):
        if table_name in self.name_2_table:
            return super().get_table_column_name(table_name)
        else:
            sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '{}';".format(table_name)
            return [x[0] for x in self.execute(sql, fetch = True)]

    def get_relation_content(self, relation_names, fetch_column_name = False):
        """Get the whole content of a relation or table
        
        :param relation_names: the name of the relation or table
        :type relation_names: str
        :param fetch_column_name: fetch the column names of the sql or not. If True, the first item of the result will be a tuple of column names.
        :type fetch_column_name: bool, optional
        :return: a list of tuple representing the result of the whole content of the relation or table
        """   
        sql = 'SELECT * from {}'.format(relation_names)
        return self.execute(sql, fetch = True, fetch_column_name = fetch_column_name)
    
    def get_column_number_of_distinct_value(self, table_name, column_name):
        """Get the number of distinct value of a column

        :param table_name: the name of the table that the column belongs to
        :type table_name: str
        :param column_name: the name of the column
        :type column_name: str
        :return: the number of distinct value, type of which is same as the data of the column
        """    
        return self.execute(f"select count(distinct {column_name}) from {table_name};", True)[0][0]


class SimulateIndexVisitor:

    def __init__(self, db_controller: PostgreSQLController):
        super().__init__()
        self.db_controller = db_controller
        self.simulated_indexes = {}

    def create_index(self, index: Index):
        columns = index.joined_column_names()
        statement = (
            "select * from hypopg_create_index( "
            f"'create index on {index.table} "
            f"({columns})')"
        )
        result = self.db_controller.execute(statement, fetch=True)[0]
        index.hypopg_oid = result[0]
        index.hypopg_name = result[1]
        self.simulated_indexes[index.hypopg_oid] = index

    def drop_index(self, index: Index):
        oid = index.hypopg_oid
        statement = f"select * from hypopg_drop_index({oid})"
        result = self.db_controller.execute(statement, fetch=True)
        assert result[0][0] is True, f"Could not drop simulated index with oid = {oid}."

        self.simulated_indexes.pop(oid)

    def drop_all_indexes(self):
        indexes = list(self.simulated_indexes.values())
        for index in indexes:
            self.drop_index(index)
        self.simulated_indexes.clear()

    def get_all_indexes_byte(self):
        # todo
        raise NotImplementedError

    def get_table_indexes_byte(self, table):
        # todo
        raise NotImplementedError

    def get_index_byte(self, index: Index):
        try:
            statement = f"select hypopg_relation_size({index.hypopg_oid})"
            result = self.db_controller.execute(statement, fetch=True)[0][0]
            assert result > 0, "Hypothetical index does not exist."
            return result
        except:
            raise RuntimeError

    def get_all_indexes(self):
        # sql = "SELECT * FROM hypopg_list_indexes"
        raise NotImplementedError
