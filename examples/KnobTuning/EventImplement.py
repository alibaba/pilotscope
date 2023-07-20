import random
from functools import partial
from pathlib import Path

import pandas as pd

from DBController.BaseDBController import BaseDBController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotEnum import ExperimentTimeEnum
from PilotEvent import PeriodicDbControllerEvent
from common.TimeStatistic import TimeStatistic
from examples.utils import load_training_sql

pd.set_option('display.max_columns', None)
import numpy as np
import sys

sys.path.append("../examples/KnobTuning/llamatune")
from config import config
from executors.executor import ExecutorFactory
from optimizer import get_ddpg_optimizer, get_smac_optimizer
from space import ConfigSpaceGenerator
from storage import StorageFactory
import run_ddpg, run_smac
import logging
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


class KnobPeriodicDbControllerEvent(PeriodicDbControllerEvent):

    def __init__(self, config, per_query_count, llamatune_config_file, exec_in_init=True, optimizer_type="ddpg"):
        super().__init__(config, per_query_count, exec_in_init = exec_in_init)
        self.optimizer_type = optimizer_type
        self.llamatune_config_file = llamatune_config_file

    def _load_sql(self):
        return load_training_sql(self.config.db)

    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):

        TimeStatistic.start(ExperimentTimeEnum.FIND_KNOB)
        db_controller.recover_config()
        db_controller.restart()

        conf = {
            "conf_filepath": self.llamatune_config_file,
            "seed": int(time.time()),
            "optimizer": self.optimizer_type  # "ddpg" or "smac"
        }
        config.update_from_file(conf["conf_filepath"])
        config.seed = conf["seed"]
        ### number of DBMS internal metrics being sampled
        config.num_dbms_metrics = 60

        # Set global random state
        random.seed(config.seed)
        np.random.seed(config.seed)

        # init input & output space
        spaces = ConfigSpaceGenerator.from_config(config)
        target_metric = spaces.target_metric

        # init storage class
        perf_label = 'Throughput' if target_metric == 'throughput' else 'Latency'
        columns = ['Iteration', perf_label, 'Optimum', 'Runtime']

        benchmark, workload = (
            config['benchmark_info']['name'], config['benchmark_info']['workload'])

        inner_path = Path(f'{benchmark}.{workload}') / f'seed{config.seed}'
        storage = StorageFactory.from_config(config, columns=columns, inner_path=inner_path)

        # store dbms & benchmark info in experiment state object
        benchmark_info_config = config.benchmark_info
        dbms_info_config = config.dbms_info
        results_path = Path(config['storage']['outdir']) / inner_path

        # init executor
        executor = ExecutorFactory.from_config(config, spaces, storage, parse_metrics=(self.optimizer_type == "ddpg"),
                                               num_dbms_metrics=config.num_dbms_metrics)

        if conf["optimizer"] == "ddpg":
            exp_state = run_ddpg.ExperimentState(
                dbms_info_config, benchmark_info_config, results_path, target_metric)
            optimizer = get_ddpg_optimizer(config, spaces,
                                           partial(run_ddpg.evaluate_dbms_conf, spaces, executor, storage, columns),
                                           exp_state)
        elif conf["optimizer"] == "smac":
            exp_state = run_smac.ExperimentState(
                dbms_info_config, benchmark_info_config, results_path, target_metric)
            optimizer = get_smac_optimizer(config, spaces,
                                           partial(run_smac.evaluate_dbms_conf, spaces, executor, storage, columns),
                                           exp_state)

        # evaluate on default config
        default_config = spaces.get_default_configuration()

        logger.info('Evaluating Default Configuration')
        logger.debug(default_config)
        if conf["optimizer"] == "ddpg":
            perf, default_metrics = run_ddpg.evaluate_dbms_conf(spaces, executor, storage, columns, default_config,
                                                                state=exp_state)
            assert len(default_metrics) == config.num_dbms_metrics, \
                ('DBMS metrics number does not match with expected: '
                 f'[ret={len(default_metrics)}] [exp={config.num_dbms_metrics}]')
        elif conf["optimizer"] == "smac":
            perf = run_smac.evaluate_dbms_conf(spaces, executor, storage, columns, default_config, state=exp_state)
        perf = perf if exp_state.minimize else -perf
        assert perf >= 0, \
            f'Performance should not be negative: perf={perf}, metric={target_metric}'

        # set starting point for worse performance
        exp_state.worse_perf = perf * 4 if exp_state.minimize else perf / 4

        if conf["optimizer"] == "ddpg":
            # run DDPG
            optimizer.run()
        else:
            optimizer.optimize()

        # Print final stats
        logger.info(f'\nBest Configuration:\n{exp_state.best_conf}')
        if target_metric == 'throughput':
            logger.info(f'Throughput: {exp_state.best_perf} ops/sec')
        else:
            logger.info(f'95-th Latency: {exp_state.best_perf} milliseconds')
        logger.info(f'Saved @ {storage.outdir}')

        db_controller.write_knob_to_file(dict(exp_state.best_conf))
        db_controller.restart()
        TimeStatistic.end(ExperimentTimeEnum.FIND_KNOB)
