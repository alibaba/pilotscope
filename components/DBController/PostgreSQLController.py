import os
from abc import ABC

from sqlalchemy import Table, Column, select, func, text, inspect
from sqlalchemy.exc import OperationalError
from typing_extensions import deprecated

from PilotConfig import PostgreSQLConfig
from common.Util import pilotscope_exit
from DBController.BaseDBController import BaseDBController
from Exception.Exception import DBStatementTimeoutException, DatabaseCrashException, DatabaseStartException
from common.Index import Index


class PostgreSQLController(BaseDBController):
    instances = set()

    def __new__(cls, *args, **kwargs):
        instance = super().__new__(cls)
        cls.instances.add(instance)
        return instance

    def __del__(self):
        self.disconnect()
        type(self).instances.remove(self)

    PG_NUM_METRICS = 60
    PG_STAT_VIEWS = [
        "pg_stat_archiver", "pg_stat_bgwriter",  # global
        "pg_stat_database", "pg_stat_database_conflicts",  # local
        "pg_stat_user_tables", "pg_statio_user_tables",  # local
        "pg_stat_user_indexes", "pg_statio_user_indexes"  # local
    ]
    PG_STAT_VIEWS_LOCAL_DATABASE = ["pg_stat_database", "pg_stat_database_conflicts"]
    PG_STAT_VIEWS_LOCAL_TABLE = ["pg_stat_user_tables", "pg_statio_user_tables"]
    PG_STAT_VIEWS_LOCAL_INDEX = ["pg_stat_user_indexes", "pg_statio_user_indexes"]
    NUMERIC_METRICS = [  # counter
        # global
        'buffers_alloc', 'buffers_backend', 'buffers_backend_fsync', 'buffers_checkpoint', 'buffers_clean',
        'checkpoints_req', 'checkpoints_timed', 'checkpoint_sync_time', 'checkpoint_write_time', 'maxwritten_clean',
        'archived_count', 'failed_count',
        # db
        'blk_read_time', 'blks_hit', 'blks_read', 'blk_write_time', 'conflicts', 'deadlocks', 'temp_bytes',
        'temp_files', 'tup_deleted', 'tup_fetched', 'tup_inserted', 'tup_returned', 'tup_updated', 'xact_commit',
        'xact_rollback', 'confl_tablespace', 'confl_lock', 'confl_snapshot', 'confl_bufferpin', 'confl_deadlock',
        # table
        'analyze_count', 'autoanalyze_count', 'autovacuum_count', 'heap_blks_hit', 'heap_blks_read', 'idx_blks_hit',
        'idx_blks_read', 'idx_scan', 'idx_tup_fetch', 'n_dead_tup', 'n_live_tup', 'n_tup_del', 'n_tup_hot_upd',
        'n_tup_ins', 'n_tup_upd', 'n_mod_since_analyze', 'seq_scan', 'seq_tup_read', 'tidx_blks_hit',
        'tidx_blks_read',
        'toast_blks_hit', 'toast_blks_read', 'vacuum_count',
        # index
        'idx_blks_hit', 'idx_blks_read', 'idx_scan', 'idx_tup_fetch', 'idx_tup_read'
    ]

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
        sql = ("SELECT name, default_version, installed_version FROM"
               " pg_available_extensions ORDER BY name;")
        res = self.execute(sql, fetch=True)
        extensions = []
        for row in res:
            extensions.append(row[0])
        return extensions

    def _create_conn_str(self):
        # postgresql://postgres@localhost/stats
        return "{}://{}@{}/{}".format("postgresql", self.config.user, self.config.host, self.config.db)

    def execute(self, sql, fetch=False):
        row = None
        try:
            self.connect_if_loss()
            conn = self.get_connection()
            result = conn.execute(text(sql) if isinstance(sql, str) else sql)
            if fetch:
                row = result.all()
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
        sql = "SET {} TO {}".format(key, value)
        self.execute(sql)

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
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

    def insert(self, table_name, column_2_value: dict):
        table = self.name_2_table[table_name]
        self.execute(table.insert().values(column_2_value))

    def create_index(self, index):
        if self.enable_simulate_index:
            self.simulate_index_visitor.create_index(index)
        else:
            column_names = index.joined_column_names()
            sql = f"create index {index.index_name} on {index.table} ({column_names});"
            self.execute(sql, fetch=False)

    def drop_index(self, index):
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
                index_name = index.index_name
                if not index_name.startswith("pgsysml_"):
                    self.drop_index(index)

    def get_all_indexes_byte(self):
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
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(table)
        else:
            # Returns size in bytes
            sql = f"select pg_indexes_size('{table}');"
            result = self.execute(sql, fetch=True)
            return float(result[0][0])

    def get_index_byte(self, index):
        if self.enable_simulate_index:
            return self.simulate_index_visitor.get_index_byte(index)
        else:
            sql = f"select pg_table_size('{index.get_index_name()}');"
            result = self.execute(sql, fetch=True)
            return int(result[0][0])

    def exist_table(self, table_name) -> bool:
        has_table = self.engine.dialect.has_table(self.get_connection(), table_name)
        if has_table:
            return True
        return False

    def get_table_row_count(self, table_name):
        stmt = select(func.count()).select_from(self.name_2_table[table_name])
        result = self.execute(stmt, fetch=True)
        return result[0][0]

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
        for instance in type(self).instances:
            # if hasattr(instance, "engine"):
            instance.disconnect() # to set DBController's self.connection_thread.conn is None
            instance.engine.dispose(close = True)
            # del instance.engine
        self._surun("{} stop -D {}".format(self.config.pg_ctl, self.config.pgdata))

    def start(self):
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

    def write_knob_to_file(self, knobs):
        with open(self.config.db_config_path, "a") as f:
            f.write("\n")
            for k, v in knobs.items():
                f.write("{} = {}\n".format(k, v))

    def recover_config(self):
        with open(self.config.backup_db_config_path, "r") as f:
            db_config_file = f.read()
        with open(self.config.db_config_path, "w") as f:
            f.write(db_config_file)

    # NOTE: modified from DBTune (MIT liscense)
    def get_internal_metrics(self):
        def parse_helper(valid_variables, view_variables):
            for view_name, variables in list(view_variables.items()):
                for var_name, var_value in list(variables.items()):
                    full_name = '{}.{}'.format(view_name, var_name)
                    if full_name not in valid_variables:
                        valid_variables[full_name] = []
                    valid_variables[full_name].append(var_value)
            return valid_variables

        try:
            metrics_dict = {
                'global': {},
                'local': {
                    'db': {},
                    'table': {},
                    'index': {}
                }
            }

            for view in self.PG_STAT_VIEWS:
                sql = 'SELECT * from {}'.format(view)
                cur = self.get_connection().connection.cursor()
                cur.execute(sql)
                results = cur.fetchall()
                columns = [col[0] for col in cur.description]
                results = [dict(zip(columns, row)) for row in results]
                if view in ["pg_stat_archiver", "pg_stat_bgwriter"]:
                    metrics_dict['global'][view] = results[0]
                else:
                    if view in self.PG_STAT_VIEWS_LOCAL_DATABASE:
                        type = 'db'
                        type_key = 'datname'
                    elif view in self.PG_STAT_VIEWS_LOCAL_TABLE:
                        type = 'table'
                        type_key = 'relname'
                    elif view in self.PG_STAT_VIEWS_LOCAL_INDEX:
                        type = 'index'
                        type_key = 'relname'
                    metrics_dict['local'][type][view] = {}
                    for res in results:
                        type_name = res[type_key]
                        metrics_dict['local'][type][view][type_name] = res

            metrics = {}
            for scope, sub_vars in list(metrics_dict.items()):
                if scope == 'global':
                    metrics.update(parse_helper(metrics, sub_vars))
                elif scope == 'local':
                    for _, viewnames in list(sub_vars.items()):
                        for viewname, objnames in list(viewnames.items()):
                            for _, view_vars in list(objnames.items()):
                                metrics.update(parse_helper(metrics, {viewname: view_vars}))

            # Combine values
            valid_metrics = {}
            for name, values in list(metrics.items()):
                if name.split('.')[-1] in self.NUMERIC_METRICS:
                    values = [float(v) for v in values if v is not None]
                    if len(values) == 0:
                        valid_metrics[name] = 0
                    else:
                        valid_metrics[name] = sum(values)
        except Exception as ex:
            print(ex)
        return valid_metrics


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
