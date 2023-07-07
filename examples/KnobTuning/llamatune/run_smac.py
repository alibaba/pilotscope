import argparse
import random
from copy import copy, deepcopy
from pathlib import Path

import pandas as pd
pd.set_option('display.max_columns', None)
import numpy as np

from config import config
from executors.executor import ExecutorFactory
from optimizer import get_new_optimizer, get_smac_optimizer
from space import ConfigSpaceGenerator
from storage import StorageFactory

from smac.facade.smac_hpo_facade import SMAC4AC

# pylint: disable=logging-fstring-interpolation
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def fix_global_random_state(seed=None):
    random.seed(seed)
    np.random.seed(seed)

class ExperimentState:
    def __init__(self, dbms_info, benchmark_info, results_path: Path, target_metric: str):
        self.iter = 0
        self.best_conf = None
        self.best_perf = None
        self.worse_perf = None
        self.default_perf_stats = None

        assert target_metric in ['throughput', 'latency'], \
            f'Unsupported target metric: {target_metric}'
        self.minimize = target_metric != 'throughput'
        self._target_metric = target_metric

        self._dbms_info = dbms_info
        self._benchmark_info = benchmark_info

        assert results_path.exists()
        self._results_path = str(results_path)

    @property
    def benchmark_info(self):
        return self._benchmark_info

    @property
    def dbms_info(self):
        return self._dbms_info

    @property
    def results_path(self) -> str:
        return self._results_path

    @property
    def target_metric(self) -> str:
        return self._target_metric

    def is_better_perf(self, perf, other):
        return (perf > other) if not self.minimize else (perf < other)

    def __str__(self):
        fields = ['iter', 'best_conf', 'best_perf', 'worse_perf',
                    'default_perf_stats', 'target_metric']
        return '<ExperimentState>:\n' + \
            '\n'.join([ f'{f}: \t{getattr(self, f)}' for f in fields ])


def evaluate_dbms_conf(spaces, executor, storage, columns, sample, state=None):

    logger.info(f'\n\n{25*"="} Iteration {state.iter:2d} {25*"="}\n\n')
    logger.info('Sample from optimizer: ')
    logger.info(sample)

    if state.iter > 0: # if not default conf
        sample = spaces.unproject_input_point(sample)
    conf = spaces.finalize_conf(sample)
    logger.info(f'Evaluating Configuration:\n{conf}')

    ## Send configuration task to Nautilus
    dbms_info = dict(
        name=state.dbms_info['name'],
        config=conf,
        version=state.dbms_info['version']
    )
    perf_stats = executor.evaluate_configuration(dbms_info, state.benchmark_info)
    logger.info(f'Performance Statistics:\n{perf_stats}')

    if state.default_perf_stats is None:
        state.default_perf_stats = perf_stats

    target_metric = state.target_metric
    if perf_stats is None:
        # Error while evaluating conf -- set some reasonable value for target metric
        runtime, perf = 0, state.worse_perf
    else:
        if target_metric == 'latency' and \
            perf_stats['throughput'] < state.default_perf_stats['throughput']:
            # Throughput less than default -- invalid round
            runtime, perf = perf_stats['runtime'], state.worse_perf
        else:
            runtime, perf = perf_stats['runtime'], perf_stats[target_metric]

    logger.info(f'Evaluation took {runtime} seconds')
    if target_metric == 'throughput':
        logger.info(f'Throughput: {perf} ops/sec')
    elif target_metric == 'latency':
        logger.info(f'95-th Latency: {perf} milliseconds')
    else:
        raise NotADirectoryError()

    if (perf_stats is not None) and ('sample' in perf_stats):
        sample = perf_stats['sample']
        logger.info(f'Point evaluated was: {sample}')

    # Keep best-conf updated
    if (state.best_perf is None) or state.is_better_perf(perf, state.best_perf):
        state.best_conf, state.best_perf = copy(sample), perf
    if (state.worse_perf is None) or not state.is_better_perf(perf, state.worse_perf):
        state.worse_perf = perf

    # Update optimizer results
    storage.store_result_summary(
        dict(zip(columns, [state.iter, perf, state.best_perf, runtime])))
    state.iter += 1

    # Register sample to the optimizer -- optimizer always minimizes
    return perf if state.minimize else -perf


if __name__ =="__main__":
    # Parse args
    parser = argparse.ArgumentParser()
    parser.add_argument('conf_filepath')
    parser.add_argument('seed', type=int)
    args = parser.parse_args()

    config.update_from_file(args.conf_filepath)
    config.seed = args.seed

    # Set global random state
    fix_global_random_state(seed=config.seed)

    # init input & output space
    spaces = ConfigSpaceGenerator.from_config(config)
    target_metric = spaces.target_metric

    # init storage class
    perf_label = 'Throughput' if target_metric == 'throughput' else 'Latency'
    columns = ['Iteration', perf_label, 'Optimum', 'Runtime']

    benchmark, workload = (
        config['benchmark_info']['name'], config['benchmark_info']['workload'])

    inner_path = Path(f'{benchmark}.{workload}') / f'seed{args.seed}'
    storage = StorageFactory.from_config(config, columns=columns, inner_path=inner_path)


    # store dbms & benchmark info in experiment state object
    benchmark_info_config = config.benchmark_info
    dbms_info_config = config.dbms_info
    results_path = Path(config['storage']['outdir']) / inner_path

    exp_state = ExperimentState(
        dbms_info_config, benchmark_info_config, results_path, target_metric)

    # Create a new optimizer
    optimizer = get_smac_optimizer(config, spaces, evaluate_dbms_conf, exp_state)

    # init executor
    executor = ExecutorFactory.from_config(config, spaces, storage)

    # evaluate on default config
    default_config = spaces.get_default_configuration()
    logger.info('Evaluating Default Configuration')
    logger.debug(default_config)
    perf = evaluate_dbms_conf(default_config, state=exp_state)
    perf = perf if exp_state.minimize else -perf
    assert perf >= 0, \
        f'Performance should not be negative: perf={perf}, metric={target_metric}'

    # set starting point for worse performance
    exp_state.worse_perf = perf * 4 if exp_state.minimize else perf / 4

    # Start optimization loop
    if hasattr(optimizer, 'optimize'):
        optimizer.optimize()    # SMAC
    else:
        optimizer.run()         # OpenBox


    # Print final stats
    logger.info(f'\nBest Configuration:\n{exp_state.best_conf}')
    if target_metric == 'throughput':
        logger.info(f'Throughput: {exp_state.best_perf} ops/sec')
    else:
        logger.info(f'95-th Latency: {exp_state.best_perf} milliseconds')
    logger.info(f'Saved @ {storage.outdir}')
