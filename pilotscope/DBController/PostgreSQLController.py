import os
import re

from sqlalchemy import text
from sqlalchemy.exc import OperationalError

from pilotscope.Common.Index import Index
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Exception.Exception import DBStatementTimeoutException, DatabaseCrashException, DatabaseStartException
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.Common.SSHConnector import SSHConnector

class PostgreSQLController(BaseDBController):
    instances = set()

    def __new__(cls, *args, **kwargs):
        instance = super().__new__(cls)
        cls.instances.add(instance)
        return instance

    def __del__(self):
        self._disconnect()
        type(self).instances.remove(self)

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
        return "{}://{}:{}@{}:{}/{}?{}".format("postgresql", self.config.db_user, self.config.db_user_pwd, self.config.db_host,
                                               self.config.db_port, self.config.db, "connect_timeout=2")

    def execute(self, sql, fetch=False, fetch_column_name=False):
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
            if "PilotScopePullEnd" not in str(e):
                raise e
        return row

    def set_hint(self, key, value):
        sql = "SET {} TO {}".format(key, value)
        self.execute(sql)

    def create_index(self, index: Index):
        if self.enable_simulate_index:
            self.simulate_index_visitor.create_index(index)
        else:
            column_names = index.joined_column_names()
            sql = f"create index {index.index_name} on {index.table} ({column_names});"
            self.execute(sql, fetch=False)

    def drop_index(self, index: Index):
        if self.enable_simulate_index:
            self.simulate_index_visitor.drop_index(index)
        else:
            # todo
            if "pgsysml" in index.index_name:
                return
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
        if self.enable_simulate_index:
            result = self.simulate_index_visitor.get_all_indexes_byte()
        else:
            sql = ("select sum(pg_indexes_size(table_name::text)) from "
                   "(select table_name from information_schema.tables "
                   "where table_schema='public') as all_tables;")
            result = float(self.execute(sql, fetch=True)[0][0])
        return result

    def get_table_indexes_byte(self, table):
        if self.enable_simulate_index:
            result = self.simulate_index_visitor.get_table_indexes_byte(table)
        else:
            sql = f"select pg_indexes_size('{table}');"
            result = float(self.execute(sql, fetch=True)[0][0])
        return result

    def get_index_byte(self, index: Index):
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(index)
        sql = f"select pg_table_size('{index.get_index_name()}');"
        result = int(self.execute(sql, fetch=True)[0][0])
        return result

    def get_existed_index(self, table):
        """
        Retrieves the existing index on the specified table.

        :param table: The name of the table to retrieve index information for.
        :type table: str

        :return: The index information of the specified table. The format of the returned
                data will depend on the implementation of get_existed_index in the subclass
                or the simulate_index_visitor.
        :rtype: list
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_existed_index(table)
        else:
            return super().get_existed_index(table)

    def get_all_indexes(self):
        """
        Retrieves all indexes across all tables in the database.

        :return: A collection containing the details of all indexes. The format of this
                collection can vary depending on the implementation in the simulate_index_visitor
                or the parent class's method.
        :rtype: list
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_all_indexes()
        else:
            return super().get_all_indexes()

    def get_index_number(self, table):
        """
        Retrieves the number of indexes defined on the specified table.

        :param table: The name of the table for which to count indexes.
        :type table: str

        :return: The number of indexes on the specified table.
        :rtype: int
        """
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_number(table)
        else:
            return super().get_index_number(table)

    def explain_physical_plan(self, sql, comment=""):
        return self._explain(sql, comment, False)

    def explain_execution_plan(self, sql, comment=""):
        return self._explain(sql, comment, True)

    def get_estimated_cost(self, sql, comment=""):
        """
        Estimates the cost of a SQL query.

        :param sql: The SQL query for which to estimate the cost.
        :type sql: str

        :param comment: An optional comment to include with the query plan. Useful for debugging.
        :type comment: str

        :return: The estimated total cost of executing the SQL query.
        :rtype: float
        """
        plan = self.explain_physical_plan(sql, comment=comment)
        return plan["Plan"]["Total Cost"]

    def get_explain_sql(self, sql, execute: bool, comment=""):
        """
        Constructs an EXPLAIN SQL statement for a given SQL query.

        :param sql: The SQL query to explain.
        :type sql: str

        :param execute: A boolean flag indicating whether to include the ANALYZE option.
                        If True, the ANALYZE option is included, and the query will be executed.
        :type execute: bool

        :param comment: An optional comment to add context to the EXPLAIN statement.
        :type comment: str

        :return: The constructed EXPLAIN SQL statement.
        :rtype: str
        """
        return "{} explain ({} VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
                                                                                   "ANALYZE," if execute else "",
                                                                                   sql)

    def get_buffercache(self):
        """
        Get the numbers of buffer per table in the shared buffer cache in real time.

        :return: a dict, of which keys are the names of table and values are the numbers of buffer per table
        :rtype: dict
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
        su_and_cmd = "su {} -c '{}'".format(self.config.db_user, cmd)
        if self.config.is_local:
            return os.system(su_and_cmd)
        else:
            ssh_conn = SSHConnector(self.config.db_host, self.config.db_host_user, self.config.db_host_pwd, self.config.db_host_port)
            ssh_conn.connect()
            ssh_conn.remote_exec_cmd(su_and_cmd)
            ssh_conn.close()
        
    def shutdown(self):
        """Shutdown the local DBMS
        """
        for instance in type(self).instances:
            # if hasattr(instance, "engine"):
            instance._disconnect()  # to set DBController's self.connection_thread.conn is None
            instance.engine.dispose(close=True)
            # del instance.engine
        self._surun("{} stop -D {} 2>&1 > /dev/null".format(self.config.pg_ctl, self.config.pgdata))

    def start(self):
        """
        Try to start DBMS. If fails the first time, recover config to self.config.backup_db_config_path and raise DatabaseStartException. If fails again after recovering config, raise DatabaseCrashException.

        :raises DatabaseStartException
        :raises DatabaseCrashException
        """
        self._surun("{} start -D {} 2>&1 > /dev/null".format(self.config.pg_ctl, self.config.pgdata))
        if "server is running" not in self.status():
            self.recover_config()
            self._surun("{} start -D {} 2>&1 > /dev/null".format(self.config.pg_ctl, self.config.pgdata))
            if "server is running" not in self.status():
                raise DatabaseStartException
            else:
                raise DatabaseCrashException
        for instance in type(self).instances:
            instance._connect_if_loss()

    def status(self):
        """
        Retrieves the status of the PostgreSQL service.

        :return: The output from the pg_ctl status command, which contains information
                about the PostgreSQL server's status.
        :rtype: str
        """
        check_db_runing_cmd = "su {} -c '{} status -D {}'".format(self.config.db_user, self.config.pg_ctl, self.config.pgdata)
        if self.config.is_local:
            res = os.popen(check_db_runing_cmd)
            return res.read()
        else:
            ssh_conn = SSHConnector(self.config.db_host, self.config.db_host_user, self.config.db_host_pwd, self.config.db_host_port)
            ssh_conn.connect()
            res_out, res_err = ssh_conn.remote_exec_cmd(check_db_runing_cmd)
            ssh_conn.close()
            return "{},{}".format(res_out, res_err)
            

    def write_knob_to_file(self, knobs: dict):
        """
        Write knobs to config file

        :param knobs: a dict with keys as the names of the knobs and values as the values to be set.
        :type knobs: dict
        """
        with open(self.config.db_config_path, "a") as f:
            f.write("\n")
            for k, v in knobs.items():
                f.write("{} = {}\n".format(k, v))

    def recover_config(self):
        """Recover config file to the file at self.config.backup_db_config_path
        """
        with open(self.config.backup_db_config_path, "r") as f:
            db_config_file = f.read()
        with open(self.config.db_config_path, "w") as f:
            f.write(db_config_file)

    def backup_config(self):
        """
        Creates a backup of the database configuration file.
        """
        with open(self.config.db_config_path, "r") as f:
            with open(self.config.backup_db_config_path, "w") as w:
                w.write(f.read())

    def get_table_column_name_all_schema(self, table_name):
        """
        Retrieves all column names for a given table across all schemas in the database.

        :param table_name: The name of the table for which to retrieve column names.
        :type table_name: str

        :return: A list of column names for the specified table.
        :rtype: list
        """
        sql = "SELECT column_name FROM information_schema.columns WHERE table_name = '{}';".format(table_name)
        return [x[0] for x in self.execute(sql, fetch=True)]

    def get_relation_content(self, relation_names, fetch_column_name=False):
        """
        Get the whole content of a relation or table
        
        :param relation_names: the name of the relation or table
        :type relation_names: str
        :param fetch_column_name: fetch the column names of the sql or not. If True, the first item of the result will be a tuple of column names.
        :type fetch_column_name: bool, optional
        :return: a list of tuple representing the result of the whole content of the relation or table
        """
        sql = 'SELECT * from {}'.format(relation_names)
        return self.execute(sql, fetch=True, fetch_column_name=fetch_column_name)

    def get_column_number_of_distinct_value(self, table_name, column_name):
        """
        Get the number of distinct value of a column

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
