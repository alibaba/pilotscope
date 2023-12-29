import json
import logging
import os
import random
import subprocess
import time
from abc import ABC, abstractmethod
from copy import deepcopy
from datetime import datetime
from pathlib import Path

import pandas as pd
import numpy as np
from scipy.spatial.distance import euclidean, cityblock

from sklearn.preprocessing import StandardScaler

from pilotscope.Exception.Exception import DatabaseCrashException
from algorithm_examples.utils import load_sql
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


def run_command(cmd, **kwargs):
    logger.debug(f'Running command: `{cmd}`...')
    logger.debug(50 * '=')

    cp = None
    try:
        cp = subprocess.run(cmd, shell=True, **kwargs)
        if cp.returncode != 0:
            logger.warn(f'Non-zero code [{cp.returncode}] for command `{cmd}`')

    except Exception as err:
        logger.error(err)
        logger.error(f'Error while running command `{cmd}`')

    return cp


def trim_disks():
    logger.info('Executing TRIM on all mount points')
    try:
        run_command('sudo fstrim -av', check=True)
    except Exception as err:
        logger.warn(f'Error while TRIMing: {repr(err)}')


def get_measured_performance(perf_stats, benchmark):
    """ Return throughput & 95-th latency percentile """
    if benchmark == 'ycsb':
        overall_stats = perf_stats['ycsb']['groups']['overall']['statistics']
        throughput, runtime = (
            overall_stats['Throughput(ops/sec)'],
            overall_stats['RunTime(ms)'] / 1000.0)

        # Check if Return=ERROR in read/update results
        error = False
        try:
            read_stats = perf_stats['ycsb']['groups']['read']['statistics']
            assert 'Return=ERROR' not in read_stats.keys()
            update_stats = perf_stats['ycsb']['groups']['update']['statistics']
            assert 'Return=ERROR' not in update_stats.keys()
        except AssertionError:
            logger.warning('Return=ERROR found in YCSB; Treating it as failed run!')
            throughput, latency = 0.1, 2 ** 30
            error = True

        if not error:
            # Manually compute latency (weighted by ops)
            groups = [
                g for name, g in perf_stats['ycsb']['groups'].items()
                if name != 'overall'
            ]
            latency_info = [  # latencies are in micro-seconds
                (float(g['statistics']['p95']), int(g['statistics']['Return=OK']))
                for g in groups
            ]
            latencies, weights = tuple(zip(*latency_info))
            latency = np.average(latencies, weights=weights) / 1000.0

    elif benchmark == 'oltpbench':
        summary_stats = perf_stats['oltpbench_summary']
        throughput, latency, runtime = (
            summary_stats['throughput(req/sec)'],
            summary_stats['95th_lat(ms)'],
            summary_stats['time(sec)'])
    elif benchmark == 'benchbase':
        summary_stats = perf_stats['benchbase_summary']
        throughput, latency, runtime = (
            summary_stats['throughput(req/sec)'],
            summary_stats['95th_lat(ms)'],
            summary_stats['time(sec)'])
    else:
        raise NotImplementedError(f'Benchmark `{benchmark}` is not supported')

    return {
        'throughput': throughput,
        'latency': latency,
        'runtime': runtime,
    }


def get_dbms_metrics(results, num_expected):
    """ Parses DBMS metrics and returns their mean as a numpy array

    NOTE: Currently only DB-wide metrics are parsed; not table-wide ones
    """
    GLOBAL_STAT_VIEWS = ['pg_stat_bgwriter', 'pg_stat_database']
    PER_TABLE_STAT_VIEWS = [  # Not used currently
        'pg_stat_user_tables',
        'pg_stat_user_indexes',
        'pg_statio_user_tables',
        'pg_statio_user_indexes'
    ]
    try:
        metrics = json.loads(results['samplers']['db_metrics'])['postgres']
        samples = metrics['samples']
    except Exception as err:
        logger.error(f'Error while *retrieving* DBMS metrics: {repr(err)}')
        logger.info('Returning dummy (i.e., all zeros) metrics')
        return np.zeros(num_expected)

    try:
        global_dfs = []
        for k in GLOBAL_STAT_VIEWS:
            s = samples[k]
            v = [l for l in s if l != None]
            cols = [f'{k}_{idx}' for idx in range(len(v[0]))]

            df = pd.DataFrame(data=v, columns=cols)
            df.dropna(axis=1, inplace=True)
            df = df.select_dtypes(['number'])
            global_dfs.append(df)

        df = pd.concat(global_dfs, axis=1)
        metrics = df.mean(axis=0).to_numpy()
    except Exception as err:
        logger.error(f'Error while *parsing* DBMS metrics: {repr(err)}')
        logger.info('Returning dummy (i.e., all zeros) metrics')
        return np.zeros(num_expected)

    if len(metrics) != num_expected:
        logger.error(f'Num of metrics [{len(metrics)}] is different than expected [{num_expected}] :(')
        logger.info('Returning dummy (i.e., all zeros) metrics')
        return np.zeros(num_expected)

    return metrics


def is_result_valid(results, benchmark):
    # Check results
    run_info, perf_stats = results['run_info'], results['performance_stats']

    if benchmark == 'ycsb':
        check_fields = [
            run_info['warm_up']['result'],
            run_info['benchmark']['result'],
            perf_stats['ycsb_result'],
            perf_stats['ycsb_raw_result'],
        ]
    elif benchmark == 'oltpbench':
        check_fields = [
            run_info['benchmark']['result'],
            perf_stats['oltpbench_summary_result'],
        ]
    elif benchmark == 'benchbase':
        check_fields = [
            run_info['benchmark']['result'],
            perf_stats['benchbase_summary_result'],
        ]
    else:
        raise NotImplementedError(f'Benchmark `{benchmark}` is not supported')

    return all(v == 'ok' for v in check_fields)


class ExecutorInterface(ABC):
    def __init__(self, spaces, storage, **kwargs):
        self.spaces = spaces
        self.storage = storage

    @abstractmethod
    def evaluate_configuration(self, dbms_info, benchmark_info):
        raise NotImplementedError


class DummyExecutor(ExecutorInterface):
    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics

    def evaluate_configuration(self, dbms_info, benchmark_info):
        perf = {
            'throughput': float(random.randint(1000, 10000)),
            'latency': float(random.randint(1000, 10000)),
            'runtime': 0,
        }

        if not self.parse_metrics:
            return perf

        metrics = np.random.rand(self.num_dbms_metrics)
        return perf, metrics


from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig


class SysmlExecutor(ExecutorInterface):
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

    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics
        # self.thread=int(kwargs["thread"])
        self.sqls_file_path = kwargs["sqls_file_path"]
        # self.timeout_per_sql=int(kwargs["timeout_per_sql"]) # ms
        config = PostgreSQLConfig()
        config.enable_deep_control_local(example_pg_bin, example_pgdata)
        config.db = kwargs["db_name"]
        config.once_request_timeout = 120
        config.sql_execution_timeout = 120
        self.data_interactor = PilotDataInteractor(config)
        self.db_controller = self.data_interactor.db_controller

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

        metrics_dict = {
            'global': {},
            'local': {
                'db': {},
                'table': {},
                'index': {}
            }
        }
        for view in self.PG_STAT_VIEWS:
            columns, *results = self.db_controller.execute("select * from {}".format(view), fetch_column_name=True)
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
                try:
                    values = [float(v) for v in values if v is not None]
                except Exception as e:
                    print(metrics)
                    print(name, values)
                    raise e
                if len(values) == 0:
                    valid_metrics[name] = 0
                else:
                    valid_metrics[name] = sum(values)
        return valid_metrics

    def evaluate_configuration(self, dbms_info, benchmark_info):
        with open(self.sqls_file_path, "r") as f:
            sqls = f.readlines()
        try:
            self.data_interactor.push_knob(dbms_info["config"])
            self.data_interactor.pull_execution_time()
            # first sql: set knob and exec
            accu_execution_time = 0
            execution_times = []
            data = self.data_interactor.execute(sqls[0], is_reset=True)
            if data is None or data.execution_time is None:
                raise TimeoutError
            else:
                execution_times.append(data.execution_time)
                accu_execution_time += data.execution_time
            # the latter sql: use previous knob and exec
            self.data_interactor.pull_execution_time()
            for i, sql in enumerate(sqls[1:]):
                data = self.data_interactor.execute(sql, is_reset=(i == len(sqls) - 1))
                if data is None or data.execution_time is None:
                    raise TimeoutError
                    execution_times.append(self.db_controller.config.once_request_timeout)
                    accu_execution_time += self.db_controller.config.once_request_timeout
                else:
                    execution_times.append(data.execution_time)
                    accu_execution_time += data.execution_time
            perf = {"latency": sorted(execution_times)[int(0.95 * len(sqls))], "runtime": accu_execution_time,
                    "throughput": len(sqls) / accu_execution_time}
            if not self.parse_metrics:
                return perf
            res = self.get_internal_metrics()
            metrics = np.array([v for _, v in sorted(res.items())])
            return perf, metrics
        except TimeoutError:
            perf = None
            if not self.parse_metrics:
                return perf
            res = self.get_internal_metrics()
            metrics = np.array([v for _, v in sorted(res.items())])
            return perf, metrics
        except DatabaseCrashException as e:
            self.db_controller.recover_config()
            self.db_controller.restart()
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise e
        finally:
            # recover config at last
            self.db_controller.recover_config()


from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum


class SparkExecutor(ExecutorInterface):
    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        from pilotscope.DBController.SparkSQLController import SparkConfig, SparkSQLDataSourceEnum
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics
        self.sqls_file_path = kwargs["sqls_file_path"]
        self.config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        self.config.once_request_timeout = 120
        self.config.sql_execution_timeout = 120
        self.config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        self.config.use_postgresql_datasource(
            db_host='localhost',
            db_port="5432",
            db='stats_tiny',
            db_user='pilotscope',
            db_user_pwd='pilotscope'
        )
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.driver.memory": "20g",
            "spark.executor.memory": "20g",
            "spark.network.timeout": "1200s",
            "spark.executor.heartbeatInterval": "600s",
            "spark.sql.cbo.enabled": True,
            "spark.sql.cbo.joinReorder.enabled": True,
            "spark.sql.pilotscope.enabled": True
        })
        self.data_interactor = PilotDataInteractor(self.config)
        self.db_controller = self.data_interactor.db_controller

    def evaluate_configuration(self, dbms_info, benchmark_info):
        sqls = load_sql(self.sqls_file_path)
        try:
            self.data_interactor.push_knob(dbms_info["config"])
            self.data_interactor.pull_execution_time()
            # first sql: set knob and exec
            accu_execution_time = 0
            execution_times = []
            data = self.data_interactor.execute(sqls[0], is_reset=True)
            if data is None or data.execution_time is None:
                raise TimeoutError
            else:
                execution_times.append(data.execution_time)
                accu_execution_time += data.execution_time
            # the latter sql: use previous knob and exec
            self.data_interactor.pull_execution_time()
            for i, sql in enumerate(sqls[1:]):
                data = self.data_interactor.execute(sql, is_reset=(i == len(sqls) - 1))
                if data is None or data.execution_time is None:
                    raise TimeoutError
                    execution_times.append(self.db_controller.config.once_request_timeout)
                    accu_execution_time += self.db_controller.config.once_request_timeout
                else:
                    execution_times.append(data.execution_time)
                    accu_execution_time += data.execution_time
            perf = {"latency": sorted(execution_times)[int(0.95 * len(sqls))], "runtime": accu_execution_time,
                    "throughput": len(sqls) / accu_execution_time}
            if not self.parse_metrics:
                return perf
            res = self.get_internal_metrics()
            metrics = np.array([v for _, v in res.items()])
            return perf, metrics
        except TimeoutError:
            perf = None
            if not self.parse_metrics:
                return perf
            res = self.get_internal_metrics()
            metrics = np.array([v for _, v in sorted(res.items())])
            return perf, metrics
        except DatabaseCrashException as e:
            raise e
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise e
        finally:
            # recover config at last
            self.db_controller.recover_config()


class ExecutorFactory:
    concrete_classes = {
        'DummyExecutor': DummyExecutor,
        "SysmlExecutor": SysmlExecutor,
        "SparkExecutor": SparkExecutor
    }

    @staticmethod
    def from_config(config, spaces, storage, **extra_kwargs):
        executor_config = deepcopy(config['executor'])

        classname = executor_config.pop('classname', None)
        assert classname != None, 'Please specify the *executor* class name'

        try:
            class_ = ExecutorFactory.concrete_classes[classname]
        except KeyError:
            raise ValueError(f'Executor class "{classname}" not found. '
                             f'Options are [{", ".join(ExecutorFactory.concrete_classes.keys())}]')

        # Override with local
        executor_config.update(**extra_kwargs)

        return class_(spaces, storage, **executor_config)
