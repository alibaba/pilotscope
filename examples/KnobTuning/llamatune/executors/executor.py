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

from Exception.Exception import DatabaseCrashException

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
            latency_info = [ # latencies are in micro-seconds
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
    PER_TABLE_STAT_VIEWS = [ # Not used currently
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
        global_dfs = [ ]
        for k in GLOBAL_STAT_VIEWS:
            s = samples[k]
            v = [ l for l in s if l != None ]
            cols = [ f'{k}_{idx}' for idx in range(len(v[0])) ]

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

import sys
sys.path.append("../")
sys.path.append("../components")# TODO :after installing baihe_lib as a package, del it

from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig

class SysmlExecutor(ExecutorInterface):
    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics
        # self.thread=int(kwargs["thread"])
        self.sqls_file_path=kwargs["sqls_file_path"]
        # self.timeout_per_sql=int(kwargs["timeout_per_sql"]) # ms
        config = PilotConfig()
        config.once_request_timeout = 120
        config.sql_execution_timeout = 120
        self.state_manager = PilotStateManager(config)
        self.db_controller = self.state_manager.db_controller
        
    def evaluate_configuration(self, dbms_info, benchmark_info):
        with open(self.sqls_file_path,"r") as f:
            sqls = f.readlines()
        try:
            self.state_manager.set_knob(dbms_info["config"])
            self.state_manager.fetch_execution_time()
            # first sql: set knob and exec
            accu_execution_time = 0
            execution_times = []
            data = self.state_manager.execute(sqls[0], is_reset=True)
            if data.execution_time is None:
                raise TimeoutError
            else:
                execution_times.append(data.execution_time)
                accu_execution_time += data.execution_time
            # the latter sql: use previous knob and exec
            self.state_manager.fetch_execution_time()
            for i, sql in enumerate(sqls[1:]):
                data = self.state_manager.execute(sql, is_reset=(i == len(sqls) - 1))
                if data.execution_time is None:
                    raise TimeoutError
                    execution_times.append(self.db_controller.config.once_request_timeout)
                    accu_execution_time += self.db_controller.config.once_request_timeout
                else:
                    execution_times.append(data.execution_time)
                    accu_execution_time += data.execution_time
            perf = {"latency":sorted(execution_times)[int(0.95*len(sqls))], "runtime":accu_execution_time, "throughput":len(sqls)/accu_execution_time}
            if not self.parse_metrics:
                return perf
            res = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics
        except DatabaseCrashException as e:
            raise e
        except Exception as e:
            
            # raise e # to check bugs, uncomment here
            print(e)
            # perf = {"latency":self.state_manager.config.once_request_timeout,"runtime":self.state_manager.config.once_request_timeout*len(sqls),"throughput":1/self.state_manager.config.once_request_timeout}
            perf = None
            if not self.parse_metrics:
                return perf
            metrics = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics # this class can't raise any error when DB fail to start
        finally:
            # recover config at last
            self.db_controller.recover_config()


from DBController.SparkSQLController import SparkSQLController, SparkConfig, SUCCESS, FAILURE, SparkSQLDataSourceEnum
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from common.Index import Index
from pyspark.sql import SparkSession

class SparkExecutor(ExecutorInterface):
    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics
        self.sqls_file_path=kwargs["sqls_file_path"]
        self.config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        self.config.once_request_timeout = 120
        self.config.sql_execution_timeout = 120
        datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
        datasource_conn_info = {
            'host': 'localhost',
            'db': 'tpcds',
            'user': 'postgres',
            'pwd': 'postgres'
        }
        self.config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        self.config.set_datasource(
            datasource_type, 
            host = datasource_conn_info["host"], 
            db = datasource_conn_info["db"], 
            user = datasource_conn_info["user"], 
            pwd = datasource_conn_info["pwd"]    
        )
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.driver.memory": "20g",
            "spark.executor.memory":"20g",
            "spark.network.timeout":"1200s",
            "spark.executor.heartbeatInterval":"600s",
            "spark.sql.cbo.enabled":True,
            "spark.sql.cbo.joinReorder.enabled":True,
            "spark.sql.pilotscope.enabled": True
        })
        self.state_manager = PilotStateManager(self.config)
        self.db_controller = self.state_manager.db_controller
        
    def evaluate_configuration(self, dbms_info, benchmark_info):
        with open(self.sqls_file_path,"r") as f:
            sqls = f.readlines()
        try:
            self.state_manager.set_knob(dbms_info["config"])
            self.state_manager.fetch_execution_time()
            # first sql: set knob and exec
            accu_execution_time = 0
            execution_times = []
            data = self.state_manager.execute(sqls[0], is_reset=True)
            if data.execution_time is None:
                raise TimeoutError
            else:
                execution_times.append(data.execution_time)
                accu_execution_time += data.execution_time
            # the latter sql: use previous knob and exec
            self.state_manager.fetch_execution_time()
            for i, sql in enumerate(sqls[1:]):
                data = self.state_manager.execute(sql, is_reset=(i == len(sqls) - 1))
                if data.execution_time is None:
                    raise TimeoutError
                    execution_times.append(self.db_controller.config.once_request_timeout)
                    accu_execution_time += self.db_controller.config.once_request_timeout
                else:
                    execution_times.append(data.execution_time)
                    accu_execution_time += data.execution_time
            perf = {"latency":sorted(execution_times)[int(0.95*len(sqls))], "runtime":accu_execution_time, "throughput":len(sqls)/accu_execution_time}
            if not self.parse_metrics:
                return perf
            res = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics
        except DatabaseCrashException as e:
            raise e
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise e # to check bugs, uncomment here
            print(e)
            # perf = {"latency":self.state_manager.config.once_request_timeout,"runtime":self.state_manager.config.once_request_timeout*len(sqls),"throughput":1/self.state_manager.config.once_request_timeout}
            perf = None
            if not self.parse_metrics:
                return perf
            metrics = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics # this class can't raise any error when DB fail to start
        finally:
            # recover config at last
            self.db_controller.recover_config()

class TempSparkExecutor(ExecutorInterface):
    def __init__(self, spaces, storage, parse_metrics=False, num_dbms_metrics=None, **kwargs):
        self.parse_metrics = parse_metrics
        self.num_dbms_metrics = num_dbms_metrics
        # self.thread=int(kwargs["thread"])
        self.sqls_file_path=kwargs["sqls_file_path"]
        # self.timeout_per_sql=int(kwargs["timeout_per_sql"]) # ms
        datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
        datasource_conn_info = {
            'host': 'localhost',
            'db': 'stats',
            'user': 'postgres',
            'pwd': 'postgres'
        }
        self.config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        self.config.set_datasource(
            datasource_type, 
            host = datasource_conn_info["host"], 
            db = datasource_conn_info["db"], 
            user = datasource_conn_info["user"], 
            pwd = datasource_conn_info["pwd"]    
        )
        self.config.set_db_type(DatabaseEnum.SPARK)
        self.table_name = "lero"
        self.db_controller: SparkSQLController = DBControllerFactory.get_db_controller(self.config)
        self.sql = "select * from badges;"
        self.table = "badges"
        self.column = "date"
        self.db_controller.connect_if_loss()
        
        self.config.once_request_timeout = 120
        self.config.sql_execution_timeout = 120
        
    def evaluate_configuration(self, dbms_info, benchmark_info):
        import time
        with open(self.sqls_file_path,"r") as f:
            sqls_pg = f.readlines()
            import sqlglot
            sqls=[sqlglot.transpile(sql,read="postgres",write="spark")[0] for sql in sqls_pg]          
        try:
            execution_times=[]
            accu_execution_time = 0
            self.db_controller.write_knob_to_file(dbms_info["config"])
            for i, sql in enumerate(sqls):
                t1 = time.perf_counter()
                self.db_controller.execute(sql,fetch = True)
                t2 = time.perf_counter() - t1
                execution_times.append(t2)
                accu_execution_time += t2
            perf = {"latency":sorted(execution_times)[int(0.95*len(sqls))], "runtime":accu_execution_time, "throughput":len(sqls)/accu_execution_time}
            if not self.parse_metrics:
                return perf
            res = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics
        except DatabaseCrashException as e:
            raise e
        except Exception as e:
            import traceback
            traceback.print_exc()
            # raise e # to check bugs, uncomment here
            print(e)
            # perf = {"latency":self.state_manager.config.once_request_timeout,"runtime":self.state_manager.config.once_request_timeout*len(sqls),"throughput":1/self.state_manager.config.once_request_timeout}
            perf = None
            if not self.parse_metrics:
                return perf
            metrics = self.db_controller.get_internal_metrics()
            metrics = np.array([v for _,v in res.items()])
            return perf, metrics # this class can't raise any error when DB fail to start
        finally:
            # recover config at last
            self.db_controller.recover_config()



class ExecutorFactory:
    concrete_classes = {
        'DummyExecutor': DummyExecutor,
        "SysmlExecutor": SysmlExecutor,
        "TempSparkExecutor":TempSparkExecutor,
        "SparkExecutor":SparkExecutor
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
