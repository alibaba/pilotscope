import os
from sqlalchemy import Table, Column, select, func, text, inspect
from sqlalchemy.exc import OperationalError
from typing_extensions import deprecated
from common.Util import pilotscope_exit
from DBController.BaseDBController import BaseDBController
from Exception.Exception import DBStatementTimeoutException
from common.Index import Index


class PostgreSQLController(BaseDBController):
        
    instances = set()

    def __new__(cls, *args, **kwargs):
        instance = super().__new__(cls)
        cls.instances.add(instance)
        return instance

    def __del__(self):
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
    
    def __init__(self, config, echo=False, allow_to_create_db=False):
        super().__init__(config, echo, allow_to_create_db)

        self.simulate_index_controller = None

        self.engine = self.engine.execution_options(isolation_level="AUTOCOMMIT")
        self.connect()

    def _create_conn_str(self):
        # postgresql://postgres@localhost/stats
        return "{}://{}@{}/{}".format("postgresql", self.config.user, self.config.host, self.config.db)

    def execute(self, sql, fetch=False):
        row = None
        try:
            result = self.connection.execute(text(sql) if isinstance(sql, str) else sql)
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

    @deprecated('use execute instead')
    def execute_batch(self, sqls, fetch=False):
        try:
            for sql in sqls[:-1]:
                self.connection.execute(text(sql) if isinstance(sql, str) else sql)
            result = self.connection.execute(text(sqls[-1]) if isinstance(sqls[-1], str) else sqls[-1])
            if fetch:
                return result.all()
        except OperationalError as e:
            pilotscope_exit(e)
            if "canceling statement due to statement timeout" in str(e):
                raise DBStatementTimeoutException(str(e))
            else:
                raise e
        except Exception as e:
            if "PilotScopeFetchEnd" not in str(e):
                raise e

    def get_hint_sql(self, key, value):
        return "SET {} TO {}".format(key, value)

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

    def create_index(self, index_name, table, columns):
        column_names = ",".join(columns)
        sql = f"create index {index_name} on {table} ({column_names});"
        self.execute(sql, fetch=False)

    def drop_index(self, index_name):
        statement = (
            f"DROP INDEX IF EXISTS {index_name};"
        )
        self.execute(statement, fetch=False)

    def drop_all_indexes(self):
        stmt = "select indexname from pg_indexes where schemaname='public';"
        indexes = self.execute(stmt, fetch=True)
        for index in indexes:
            index_name: str = index[0]
            if not index_name.startswith("pgsysml_"):
                self.drop_index(index_name)

    def get_all_indexes_byte(self):
        # Returns size in bytes
        sql = ("select sum(pg_indexes_size(table_name::text)) from "
               "(select table_name from information_schema.tables "
               "where table_schema='public') as all_tables;")
        result = self.execute(sql, fetch=True)
        return float(result[0][0])

    def get_table_indexes_byte(self, table):
        # Returns size in bytes
        sql = f"select pg_indexes_size('{table}');"
        result = self.execute(sql, fetch=True)
        return float(result[0][0])

    def get_index_byte(self, index_name):
        sql = f"select pg_table_size('{index_name}');"
        result = self.execute(sql, fetch=True)
        return int(result[0][0])

    def exist_table(self, table_name) -> bool:
        has_table = self.engine.dialect.has_table(self.connection, table_name)
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

    def explain_execution_plan(self, sql, comment=""):
        return self._explain(sql, comment, True)

    def get_estimated_cost(self, sql):
        plan = self.explain_physical_plan(sql)
        return plan["Plan"]["Total Cost"]

    def get_explain_sql(self, sql, execute: bool, comment=""):
        return "{} explain (ANALYZE {}, VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
                                                                                            "" if execute else "False",
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
        res = self.connection.execute(text(sql)).all()
        return {k: v for k, v in res if not k.startswith("pg_")}

    def _explain(self, sql, comment, execute: bool):
        return self.execute(text(self.get_explain_sql(sql, execute, comment)), True)[0][0][0]
    
    # switch user and run
    def _surun(self, cmd):
        os.system("su {} -c '{}'".format(self.config.user, cmd))
    
    def shutdown(self):
        self._surun("{} stop -D {}".format(self.config.pg_ctl, self.config.pgdata))

    def start(self):
        self._surun("{} start -D {}".format(self.config.pg_ctl, self.config.pgdata))
        for instance in type(self).instances:
            instance.connect()
        
    def status(self):
        res = os.popen("su {} -c '{} status -D {}'".format(self.config.user,self.config.pg_ctl, self.config.pgdata))
        return res.read()
        
    def write_knob_to_file(self, knobs):
        with open(self.config.db_config_path, "a") as f:
            f.write("\n")
            for k,v in knobs.items():
                f.write("{} = {}\n".format(k,v))

    def recover_config(self):
        with open(self.config.backup_db_config_path, "r") as f:
            db_config_file = f.read()
        with open(self.config.db_config_path, "w") as f:
            f.write(db_config_file)

    #NOTE: modified from DBTune (MIT liscense)
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
                cur=self.connection.connection.cursor()
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


class SimulateIndexController:
    def create_index(self, index: Index):
        table_name = index.table()
        statement = (
            "select * from hypopg_create_index( "
            f"'create index on {table_name} "
            f"({index.joined_column_names()})';)"
        )
        result = self.exec_fetch(statement)
        return result
