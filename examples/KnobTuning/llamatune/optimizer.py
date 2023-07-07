import logging
from functools import partial

import numpy as np
import pandas as pd

from config import config
from adapters import LHDesignWithBiasedSampling

# SMAC
from smac.facade.smac_hpo_facade import SMAC4HPO
from smac.facade.smac_bb_facade import SMAC4BB
from smac.scenario.scenario import Scenario

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def initialize_optimizer(optimization_problem, rand_percentage=0.1, n_estimators=100):
    optimizer_config = bayesian_optimizer_config_store.default
    # set the fraction of randomly sampled configuration to 10% of suggestions
    optimizer_config.experiment_designer_config.fraction_random_suggestions = rand_percentage
    # Set multiplier for the confidence bound
    optimizer_config.experiment_designer_config.confidence_bound_utility_function_config.alpha = 0.1

    # configure the random forest surrogate mode
    random_forest_config = optimizer_config.homogeneous_random_forest_regression_model_config
    random_forest_config.decision_tree_regression_model_config.n_new_samples_before_refit = 1
    # Use the best split in trees (not random as in extremely randomized trees)
    random_forest_config.decision_tree_regression_model_config.splitter = 'best'
    # right now we're sampling without replacement so we need to subsample
    # to make the trees different when using the 'best' splitter
    #random_forest_config.samples_fraction_per_estimator = .9
    random_forest_config.samples_fraction_per_estimator = 1
    random_forest_config.n_estimators = n_estimators

    optimizer_factory = BayesianOptimizerFactory()
    return optimizer_factory.create_local_optimizer(
        optimization_problem=optimization_problem,
        optimizer_config=optimizer_config
    )

def get_new_optimizer(spaces, ignore_knobs=None, bootstrap_points=None):
    bootstrap_points = bootstrap_points or [ ]

    logger.info('Constructing new optimizer...')
    logger.info(f'Len(Evaluated points): {len(bootstrap_points)}')
    logger.info(f'Ignored knobs: {ignore_knobs}')

    # Generate input (i.e. knobs) and output (i.e. perf metric) space
    input_space = spaces.generate_input_space(ignore_extra_knobs=ignore_knobs)
    output_space = spaces.generate_output_space()

    logger.debug(f'\ninput space:\n{input_space}')
    logger.debug(f'\noutput space:\n{output_space}')

    # Initialize optimizer
    optimization_problem = OptimizationProblem(
        parameter_space=input_space,
        objective_space=output_space,
        objectives=[
            Objective(name=config['spaces']['target_metric'], minimize=False)]
    )
    rand_percentage = float(config['optimizer']['rand_percentage'])
    assert 0 <= rand_percentage <= 1, 'Optimizer rand optimizer must be between 0 and 1'

    n_estimators = int(config['optimizer']['n_estimators'])
    optimizer = initialize_optimizer(optimization_problem,
        rand_percentage=rand_percentage, n_estimators=n_estimators)

    # Fix optimizer random state
    fix_optimizer_random_state(optimizer, seed=config.seed)

    # Train optimizer with previously-evaluated points
    if len(bootstrap_points) > 0:
        samples, outputs = map(pd.concat, zip(*bootstrap_points))
        samples = samples.drop(columns=ignore_knobs) # remove pruned columns

        optimizer.register(samples, outputs) # fit optimizer with points

    return optimizer

def get_smac_optimizer(config, spaces, tae_runner, state,
        ignore_knobs=None, run_history=None):

    logger.info('Constructing new optimizer...')
    logger.info(f'Run History: {run_history}')
    logger.info(f'Ignored knobs: {ignore_knobs}')

    # Generate input (i.e. knobs) and output (i.e. perf metric) space
    input_space = spaces.generate_input_space(
        config.seed, ignore_extra_knobs=ignore_knobs)

    logger.info(f'\ninput space:\n{input_space}')

    scenario = Scenario({
        "run_obj": "quality",
        "runcount-limit": config.iters,
        "cs": input_space,
        "deterministic": "true",
        "always_race_default": "false",
        # disables pynisher, which allows for shared state
        "limit_resources": "false",
        "output_dir": state.results_path,
    })
    # Latin Hypercube design, with 10 iters
    init_rand_samples = int(config['optimizer'].get('init_rand_samples', 10))
    initial_design = LHDesignWithBiasedSampling
    initial_design_kwargs = {
        "init_budget": init_rand_samples,
        "max_config_fracs": 1,
    }

    # Get RF params from config
    rand_percentage = float(config['optimizer']['rand_percentage'])
    assert 0 <= rand_percentage <= 1, 'Optimizer rand optimizer must be between 0 and 1'
    n_estimators = int(config['optimizer']['n_estimators'])

    #  how often to evaluate a random sample
    random_configuration_chooser_kwargs = {
        'prob': rand_percentage,
    }
    tae_runner = partial(tae_runner, state=state)

    model_type = config['optimizer'].get('model_type', 'rf') # default is RF-SMACHPO
    assert model_type in ['rf', 'gp', 'mkbo'], 'Model type %s not supported' % model_type

    if model_type == 'rf':
        # RF model params -- similar to MLOS ones
        model_kwargs = {
            'num_trees': n_estimators,
            'log_y': False,         # no log scale
            'ratio_features': 1,    #
            'min_samples_split': 2, # min number of samples to perform a split
            'min_samples_leaf': 3,  # min number of smaples on a leaf node
            'max_depth': 2**20,     # max depth of tree
        }
        optimizer = SMAC4HPO(
            scenario=scenario,
            tae_runner=tae_runner,
            rng=config.seed,
            model_kwargs=model_kwargs,
            initial_design=initial_design,
            initial_design_kwargs=initial_design_kwargs,
            random_configuration_chooser_kwargs=random_configuration_chooser_kwargs,
        )

    elif model_type == 'gp':
        optimizer = SMAC4BB(
            model_type='gp',
            scenario=scenario,
            tae_runner=tae_runner,
            rng=config.seed,
            initial_design=initial_design,
            initial_design_kwargs=initial_design_kwargs,
            random_configuration_chooser_kwargs=random_configuration_chooser_kwargs,
        )

    elif model_type == 'mkbo':
        # OpenBox
        import openbox
        openbox.utils.limit._platform = 'Windows' # Patch to avoid objective function wrapping
        optimizer = openbox.Optimizer(
            tae_runner,
            input_space,
            num_objs=1,
            num_constraints=0,
            max_runs=config.iters,
            surrogate_type='gp',
            acq_optimizer_type='local_random',
            initial_runs=10,
            init_strategy='random_explore_first',
            time_limit_per_trial=10**6,
            logging_dir=state.results_path,
            random_state=config.seed,
        )

    logger.info(optimizer)
    return optimizer


def get_ddpg_optimizer(config, spaces, tae_runner, state):
    logger.info('Constructing new optimizer...')

    # Generate input (i.e. knobs) and output (i.e. perf metric) space
    input_space = spaces.generate_input_space(
        config.seed, ignore_extra_knobs=None)
    logger.info(f'\ninput space:\n{input_space}')

    # random number generator
    rng = np.random.RandomState(seed=config.seed)

    from smac.stats.stats import Stats
    from smac.utils.io.traj_logging import TrajLogger
    from smac.utils.io.output_directory import create_output_directory

    scenario = Scenario({
        "run_obj": "quality",
        "runcount-limit": config.iters,
        "cs": input_space,
        "deterministic": "true",
        "always_race_default": "false",
        # disables pynisher, which allows for shared state
        "limit_resources": "false",
        "output_dir": state.results_path,
    })

    output_dir = create_output_directory(scenario, 0)
    stats = Stats(scenario)
    traj_logger = TrajLogger(output_dir=output_dir, stats=stats)

    # Latin Hypercube design, with 10 iters
    init_rand_samples = int(config['optimizer'].get('init_rand_samples', 10))
    init_design_def_kwargs = {
        "cs": input_space,
        "rng": rng,
        "traj_logger": traj_logger, # required
        "ta_run_limit": 99999999999,
        "max_config_fracs": 1,
        "init_budget": init_rand_samples,
    }
    initial_design = LHDesignWithBiasedSampling(**init_design_def_kwargs)

    # Random conf chooser
    from smac.optimizer.random_configuration_chooser import ChooserProb

    rand_percentage = float(config['optimizer']['rand_percentage'])
    assert 0 <= rand_percentage <= 1, 'Optimizer rand optimizer must be between 0 and 1'
    rcc_rng = np.random.RandomState(seed=config.seed)
    rand_conf_chooser = ChooserProb(rcc_rng, rand_percentage)

    # DDPG Model
    from ddpg.ddpg import DDPG, DDPGOptimizer
    n_states = config.num_dbms_metrics
    n_actions = len(input_space)

    model = DDPG(n_states, n_actions, model_name='ddpg_model')

    tae_runner = partial(tae_runner, state=state)
    optimizer = DDPGOptimizer(state, model, tae_runner, initial_design, rand_conf_chooser,
                            config.iters, logging_dir=state.results_path)

    return optimizer
