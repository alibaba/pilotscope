import os
import re

from sqlalchemy import text
from sqlalchemy.exc import OperationalError

from pilotscope.Common.Index import Index
from pilotscope.Common.SSHConnector import SSHConnector
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Exception.Exception import DBStatementTimeoutException, DatabaseCrashException, DatabaseStartException, \
    PilotScopeInternalError
from pilotscope.PilotConfig import PostgreSQLConfig


class PostgreSQLController(BaseDBController):
    _instances = set()

    def __new__(cls, *args, **kwargs):
        instance = super().__new__(cls)
        cls._instances.add(instance)
        return instance

    def __del__(self):
        self._disconnect()
        type(self)._instances.remove(self)

    def __init__(self, config: PostgreSQLConfig, echo=True, enable_simulate_index=False):
        super().__init__(config, echo)
        self.config: PostgreSQLConfig = config

        self.enable_simulate_index = enable_simulate_index
        self._add_extension()
        if self.enable_simulate_index:
            self.simulate_index_visitor = SimulateIndexVisitor(self)
            for index in super().get_all_indexes():
                sql = f"SELECT hypopg_hide_index('{index.index_name}'::REGCLASS)"
                self.execute(sql)

    def _add_extension(self):
        extensions = self.get_available_extensions()
        if "pg_buffercache" not in extensions:
            self.execute("create extension pg_buffercache")
        if "pg_hint_plan" not in extensions:
            self.execute("create extension pg_hint_plan")
        if self.enable_simulate_index and "hypopg" not in extensions:
            self.execute("create extension hypopg")

    def get_available_extensions(self):
        """
        Get all extensions that have installed in the connected database
        :return: the list of extension names
        """
        sql = ("SELECT name, default_version, installed_version FROM"
               " pg_available_extensions WHERE installed_version is not NULL ORDER BY name;")
        res = self.execute(sql, fetch=True)
        extensions = []
        for row in res:
            extensions.append(row[0])
        return extensions

    def _create_conn_str(self):
        return "{}://{}:{}@{}:{}/{}?{}".format("postgresql", self.config.db_user, self.config.db_user_pwd,
                                               self.config.db_host,
                                               self.config.db_port, self.config.db, "connect_timeout=2")

    def execute(self, sql, fetch=False, fetch_column_name=False):
        """
        Execute a SQL query.

        :param sql: the SQL query to execute
        :param fetch: it indicates whether to fetch the result of the query
        :param fetch_column_name: it indicates whether to fetch the column names of the result.
        :return: the result of the query if fetch is True, otherwise None
        """
        row = None
        try:
            self._connect_if_loss()
            conn = self._get_connection()
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
            if "Can not find the corresponding sub-plan query in push anchor" in str(e):
                raise PilotScopeInternalError(str(e))
            if "PilotScopePullEnd" not in str(e):
                raise e
        return row

    def set_hint(self, key, value):
        """
        Set the value of each hint (i.e., the run-time config) when execute SQL queries.
        The hints can be used to control the behavior of the database system in a session.
        For PostgreSQL, you can find all valid hints in https://www.postgresql.org/docs/13/runtime-config.html.

        :param key: the name of the hint
        :param value: the value of the hint
        """
        sql = "SET {} TO {}".format(key, value)
        self.execute(sql)

    def create_index(self, index: Index):
        """
        Create an index on columns `index.columns` of table `index.table` with name `index.index_name`.

        :param index: a Index object including the information of the index
        """
        if self.enable_simulate_index:
            self.simulate_index_visitor.create_index(index)
        else:
            column_names = index.joined_column_names()
            sql = f"create index {index.index_name} on {index.table} ({column_names});"
            self.execute(sql, fetch=False)

    def drop_index(self, index: Index):
        """
        Drop an index by its index name.

        :param index: an index that will be dropped
        """
        if self.enable_simulate_index:
            self.simulate_index_visitor.drop_index(index)
        else:
            statement = (
                f"DROP INDEX IF EXISTS {index.index_name};"
            )
            self.execute(statement, fetch=False)

    def drop_all_indexes(self):
        """
        Drop all indexes across all tables in the database. This will not delete the system indexes and unique indexes.
        """
        if self.enable_simulate_index:
            self.simulate_index_visitor.drop_all_indexes()
        else:
            indexes = self.get_all_indexes()
            for index in indexes:
                self.drop_index(index)

    def get_all_indexes_byte(self):
        """
        Get the size of all indexes across all tables in the database in bytes.
        This will include the system indexes and unique indexes.

        :return: the size of all indexes in bytes
        """
        if self.enable_simulate_index:
            result = self.simulate_index_visitor.get_all_indexes_byte()
        else:
            sql = ("select sum(pg_indexes_size(table_name::text)) from "
                   "(select table_name from information_schema.tables "
                   "where table_schema='public') as all_tables;")
            result = float(self.execute(sql, fetch=True)[0][0])
        return result

    def get_table_indexes_byte(self, table_name):
        """
        Get the size of all indexes on a table in bytes.
        This will include the system indexes and unique indexes.

        :param table_name: a table name that the indexes belong to
        :return: the size of all indexes on the table in bytes
        """
        if self.enable_simulate_index:
            result = self.simulate_index_visitor.get_table_indexes_byte(table_name)
        else:
            sql = f"select pg_indexes_size('{table_name}');"
            result = float(self.execute(sql, fetch=True)[0][0])
        return result

    def get_index_byte(self, index: Index):
        """
        Get the size of an index in bytes by its index name.

        :param index: the index to get size
        :return: the size of the index in bytes
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(index)
        sql = f"select pg_table_size('{index.get_index_name()}');"
        result = int(self.execute(sql, fetch=True)[0][0])
        return result

    def get_existed_indexes(self, table):
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_existed_index(table)
        else:
            return super().get_existed_indexes(table)

    def get_all_indexes(self):
        """
        Get all indexes across all tables in the database.

        :return: A collection containing the details of all indexes.
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_all_indexes()
        else:
            return super().get_all_indexes()

    def get_index_number(self, table):
        """
        Get the number of indexes built on the specified table.

        :param table: The name of the table for which to count indexes.
        :return: The number of indexes on the specified table.
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_number(table)
        else:
            return super().get_index_number(table)

    def explain_physical_plan(self, sql, comment=""):
        """
        Get the physical plan from database's optimizer of a SQL query.

        :param sql: The SQL query to be explained.
        :param comment: A SQL comment will be added to the beginning of the SQL query.
        :return: The physical plan of the SQL query.
        """
        return self._explain(sql, comment, False)

    def explain_execution_plan(self, sql, comment=""):
        """
        Get the execution plan from database's optimizer of a SQL query.

        :param sql: The SQL query to be explained.
        :param comment: A SQL comment will be added to the beginning of the SQL query.
        :return: The execution plan of the SQL query.
        """
        return self._explain(sql, comment, True)

    def _explain(self, sql, comment, execute: bool):
        return self.execute(text(self.get_explain_sql(sql, execute, comment)), True)[0][0][0]

    def get_estimated_cost(self, sql, comment=""):
        """
        Get an estimated cost of a SQL query.

        :param sql: The SQL query for which to estimate the cost.
        :param comment:  A SQL comment will be added to the beginning of the SQL query.
        :return: The estimated total cost of executing the SQL query.
        """
        plan = self.explain_physical_plan(sql, comment=comment)
        return plan["Plan"]["Total Cost"]

    def get_explain_sql(self, sql, execute: bool, comment=""):
        """
        Constructs an EXPLAIN SQL statement for a given SQL query.

        :param sql: The SQL query to explain.
        :param execute: A boolean flag indicating whether to execute the query plan.
        :param comment:  A SQL comment will be added to the beginning of the SQL query.
        :return: The result of executing the `EXPLAIN` SQL statement.
        """
        return "{} explain ({} VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
                                                                                   "ANALYZE," if execute else "",
                                                                                   sql)

    def get_buffercache(self):
        """
        Get the numbers of buffer per table in the shared buffer cache in real time.

        :return: a dict, where keys are the names of table and values are the numbers of buffer per table
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

    def shutdown(self):
        """
        Shutdown the database
        """

        self._check_enable_deep_control()

        for instance in type(self)._instances:
            # if hasattr(instance, "engine"):
            instance._disconnect()  # to set DBController's self.connection_thread.conn is None
            instance.engine.dispose(close=True)
            # del instance.engine
        self._surun("{} stop -D {} 2>&1 > /dev/null".format(self.config.pg_ctl, self.config.pgdata))

    def start(self):
        """
        Try to start DBMS. If fails the first time, recover config to self.config.backup_db_config_path and raise DatabaseStartException.
        If fails again after recovering config, raise DatabaseCrashException.

        :raises DatabaseStartException
        """

        self._check_enable_deep_control()

        self._surun("{} start -D {} 2>&1 > /dev/null".format(self.config.pg_ctl, self.config.pgdata))
        if not self.is_running():
            raise DatabaseCrashException

        for instance in type(self)._instances:
            instance._connect_if_loss()

    def is_running(self):
        """
        Check whether the database is running.

        :return: True if the database is running, False otherwise.
        """
        self._check_enable_deep_control()

        check_db_running_cmd = "su {} -c '{} status -D {}'".format(self.config.db_user, self.config.pg_ctl,
                                                                   self.config.pgdata)
        if self.config._is_local:
            with os.popen(check_db_running_cmd) as res:
                status = res.read()
        else:
            ssh_conn = SSHConnector(self.config.db_host, self.config.db_host_user, self.config.db_host_pwd,
                                    self.config.db_host_port)
            ssh_conn.connect()
            res_out, res_err = ssh_conn.remote_exec_cmd(check_db_running_cmd)
            ssh_conn.close()
            status = "{},{}".format(res_out, res_err)

        return "server is running" in status

    def write_knob_to_file(self, key_2_value_knob: dict):
        """
        Write knobs to config file, you should restart database to make it work.

        :param key_2_value_knob: a dict with keys as the names of the knobs and values as the values to be set.
        """

        self._check_enable_deep_control()

        with open(self.config.db_config_path, "a") as f:
            f.write("\n")
            for k, v in key_2_value_knob.items():
                f.write("{} = {}\n".format(k, v))

    def recover_config(self):
        """
        Recover config file of database to the lasted saved config file by `backup_config()`
        """

        self._check_enable_deep_control()

        with open(self.config.backup_db_config_path, "r") as f:
            db_config_file = f.read()
        with open(self.config.db_config_path, "w") as f:
            f.write(db_config_file)

    def backup_config(self):
        """
        Creates a backup of the database configuration file.
        """

        self._check_enable_deep_control()

        with open(self.config.db_config_path, "r") as f:
            with open(self.config.backup_db_config_path, "w") as w:
                w.write(f.read())

    def get_table_columns(self, table_name, enable_all_schema=False):
        """
        Retrieves all column names for a given table. If enable_all_schema is true,
        Pilotscope will search it across all schemas in the database.
        Otherwise, Pilotscope will only search it in the public schema.

        :param table_name: The name of the table for which to retrieve column names.
        :param enable_all_schema:
        :return: A list of column names for the specified table.
        """
        if enable_all_schema:
            sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '{}';".format(table_name)
        else:
            sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '{}' and table_schema='public';".format(
                table_name)
        return [x[0] for x in self.execute(sql, fetch=True)]

    def get_number_of_distinct_value(self, table_name, column_name):
        """
        Get the number of distinct value of a column

        :param table_name: the name of the table that the column belongs to
        :param column_name: the name of the column
        :return: the number of distinct value, type of which is same as the data of the column
        """
        return self.execute(f"select count(distinct {column_name}) from {table_name};", True)[0][0]

    # switch user and run
    def _surun(self, cmd):
        su_and_cmd = "su {} -c '{}'".format(self.config.db_user, cmd)
        if self.config._is_local:
            return os.system(su_and_cmd)
        else:
            ssh_conn = SSHConnector(self.config.db_host, self.config.db_host_user, self.config.db_host_pwd,
                                    self.config.db_host_port)
            ssh_conn.connect()
            ssh_conn.remote_exec_cmd(su_and_cmd)
            ssh_conn.close()


class SimulateIndexVisitor:

    def __init__(self, db_controller: PostgreSQLController):
        super().__init__()
        self.db_controller = db_controller

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

    def _get_oid_by_indexname(self, index_name):
        sql = f"SELECT indexrelid FROM hypopg_list_indexes WHERE index_name like '%{index_name}%'"
        res = self.db_controller.execute(sql, fetch=True)
        assert len(res) == 1, f"No oid or more than one oid named like '%{index_name}%'"
        return res[0][0]

    def _get_oid_of_index(self, index: Index):
        if index.hypopg_oid is not None:
            return index.hypopg_oid
        elif index.hypopg_name is not None:
            return self._get_oid_by_indexname(index_name=index.hypopg_name)
        else:
            return self._get_oid_by_indexname(index_name=index.index_name)

    def drop_index(self, index: Index):
        oid = self._get_oid_of_index(index)
        statement = f"select * from hypopg_drop_index({oid})"
        result = self.db_controller.execute(statement, fetch=True)
        assert result[0][0] is True, f"Could not drop simulated index with oid = {oid}."

    def drop_all_indexes(self):
        sql = "select hypopg_reset()"
        self.db_controller.execute(sql)

    def get_all_indexes_byte(self):
        return self.get_table_indexes_byte("1' or '1'='1")

    def get_table_indexes_byte(self, table):
        sql = f"SELECT sum(hypopg_relation_size(h.indexrelid)) from hypopg() h left join pg_class t on h.indrelid=t.oid where t.relname = '{table}'"
        res = self.db_controller.execute(sql, fetch=True)[0][0]
        return 0 if res is None else float(res)

    def get_index_byte(self, index: Index):
        try:
            oid = self._get_oid_of_index(index)
            statement = f"select hypopg_relation_size({oid})"
            result = self.db_controller.execute(statement, fetch=True)[0][0]
            assert result > 0, "Hypothetical index does not exist."
            return float(result)
        except:
            raise RuntimeError

    def get_index_number(self, table):
        sql = f"SELECT COUNT(*) from hypopg() h left join pg_class t on h.indrelid=t.oid where t.relname = '{table}'"
        return int(self.db_controller.execute(sql, fetch=True)[0][0])

    def get_all_indexes(self):
        return self.get_existed_index("1' or '1'='1")

    def get_existed_index(self, table):
        sql = f"SELECT h.indexrelid, h.indexname, hypopg_get_indexdef(h.indexrelid), t.relname from hypopg() h left join pg_class t on h.indrelid=t.oid where t.relname = '{table}'"
        res = self.db_controller.execute(sql, fetch=True)
        indexes = []
        for indexrelid, indexname, indexdef, relname in res:
            col = [col.strip() for col in re.search(r"\([\S\s]*\)", indexdef).group(0)[1:-1].split(",")]
            index = Index(columns=col, table=relname, index_name=None)
            index.hypopg_name = indexname
            index.hypopg_oid = indexrelid
            indexes.append(index)
        return indexes
