# LlamaTune: Sample-Efficient DBMS Configuration Tuning

This repository contains the source code for the paper "[LlamaTune: Sample-Efficient DBMS Configuration Tuning](https://arxiv.org/abs/2203.05128)" (to appear in [VLDB'22](https://vldb.org/2022)). LlamaTune is a tuning pipeline that can be integrated with existing state-of-the-art DBMS knob tuning optimizers and can achieve greater sample-efficiency, through targeted search space transformations. In particular, LlamaTune (1) reduces the dimensionality of the original configuration search space using random linear projections, (2) provides support for handling *hybrid* knobs (i.e., numerical knobs with special values), and (3) avoids the large ranges of certain knobs with value bucketization. For more information, please refer to the paper.

The code in this repository can be used to generate and output configurations suggested by LlamaTune when coupled with SMAC, Gaussian-based BO, and DDPG optimizers. Interested users can plug this code to their own tools in order to evaluate these configurations on real DBMS deployments.

## Source Code Structure

LlamaTune uses [ConfigSpace](https://automl.github.io/ConfigSpace/) to define the DBMS configuration space, and employs custom *adapters* to perform the search space transformations described in the paper.

- `adapters/`
  - `configspace/`
    - `low_embeddings.py`: random linear projections (**Sec. 3**).
    - `quantization.py`: bucketization of knob values ranges (**Sec. 4.2**).
  - `bias_sampling.py`: definition and handling of hybrid knobs (**Sec. 4.1**).
- `configs/`
  - `benchbase/*`: experiment config files for BenchBase workloads
  - `ycsb/*`: experiment config files for YCSB workloads
- `ddpg/*`: definition of the actor-critic DDPG neural network architecture used in CDBTune.
- `executors/`: auxiliary code to run workload in the DBMS through an in-house executor framework.
- `spaces/`:
  - `definitions/*`: PostgreSQL knob definition for v9.6 and v13.6.
- `config.py`: config file parsing & workload options definition
- `optimizer.py`: initialization of the BO-based or RL-based optimizer.
- `run-ddpg.py`: main script used for experiments for **BO-based** optimizers
- `run-smac.py`: main script used for experiments for **RL-based** optimizer
- `space.py`: definition of the input space that is fed to the underlying optimizer.
- `storage.py`: auxiliary code to store the result of the evaluated configurations.

**NOTE**: The complete LlamaTune pipeline, which includes low-dimensional tuning, hybrid knob handling, and large knob values bucketization is included in `adapters/configspace/low_embeddings.py`.

## Environment

We ran our experiments on [Cloudlab](https://cloudlab.us), on nodes of type`c220g5`. This repository contains knob definitions only for PostgreSQL v9.6 and v13.6; the results are presented in the paper.

Source code requires Python 3.7+ for running. To install the required packages run the following command:

```bash
pip3 install -r requirements.txt -f https://download.pytorch.org/whl/torch_stable.html
```

## Run Experiments

Main scripts used for running experiments are `run-smac.py` (for BO methods) and `run-ddpg.py` (for RL method). These can be invoked using the following syntax:

```bash
python3 run-smac.py <config_file> <seed>
```

where `<config_file>` is an experiment configuration file found in `config/*` directory, and `<seed>` is the random seed used by the optimizer. In our experiments, we used the same five different seeds (i.e., `1-5`).

Configuration files used for producing the same figure are typically grouped together in the same directory. For instance, this holds true for the sensitivity analysis performed for the low-dimensional projections, biased sampling, and bucketization techniques.

### Usage Examples

To run the "vanilla" SMAC on YCSB-A (for a single seed), one should run the following command:

```bash
python3 run-smac.py configs/ycsb/ycsbA/ycsbA.all.ini 1
```

<details>
  <summary>Example Output </summary>

  ```sh
  INFO:root:Results will be saved @ "results/ycsb.workloada/seed1"


  INFO:root:Constructing new optimizer...
  INFO:root:Run History: None
  INFO:root:Ignored knobs: None
  INFO:root:
  input space:
  Configuration space object:
    Hyperparameters:
  input
      autovacuum, Type: Categorical, Choices: {on, off}, Default: on
      autovacuum_analyze_scale_factor, Type: UniformFloat, Range: [0.0, 100.0], Default: 0.1
      autovacuum_analyze_threshold, Type: UniformInteger, Range: [0, 1000], Default: 50
      autovacuum_freeze_max_age, Type: UniformInteger, Range: [100000, 2000000000], Default: 200000000
      autovacuum_max_workers, Type: UniformInteger, Range: [1, 10000], Default: 3
      autovacuum_multixact_freeze_max_age, Type: UniformInteger, Range: [10000, 2000000000], Default: 400000000
      autovacuum_naptime, Type: UniformInteger, Range: [1, 2147483], Default: 60
      autovacuum_vacuum_cost_delay, Type: UniformInteger, Range: [-1, 100], Default: 20
      autovacuum_vacuum_cost_limit, Type: UniformInteger, Range: [-1, 10000], Default: -1
      autovacuum_vacuum_scale_factor, Type: UniformFloat, Range: [0.0, 100.0], Default: 0.2
      autovacuum_vacuum_threshold, Type: UniformInteger, Range: [0, 2147483647], Default: 50
      autovacuum_work_mem, Type: UniformInteger, Range: [-1, 1048576], Default: -1
      backend_flush_after, Type: UniformInteger, Range: [0, 256], Default: 0
      bgwriter_delay, Type: UniformInteger, Range: [10, 4000], Default: 200
      bgwriter_flush_after, Type: UniformInteger, Range: [0, 256], Default: 64
      bgwriter_lru_maxpages, Type: UniformInteger, Range: [0, 1000], Default: 100
      bgwriter_lru_multiplier, Type: UniformFloat, Range: [0.0, 8.0], Default: 2.0
      checkpoint_completion_target, Type: UniformFloat, Range: [0.0, 1.0], Default: 0.5
      checkpoint_flush_after, Type: UniformInteger, Range: [0, 256], Default: 32
      checkpoint_timeout, Type: UniformInteger, Range: [30, 86400], Default: 300
      commit_delay, Type: UniformInteger, Range: [0, 4096], Default: 0
      commit_siblings, Type: UniformInteger, Range: [0, 16], Default: 5
      cpu_index_tuple_cost, Type: UniformFloat, Range: [0.0, 4.0], Default: 0.005
      cpu_operator_cost, Type: UniformFloat, Range: [0.0, 4.0], Default: 0.0025
      cpu_tuple_cost, Type: UniformFloat, Range: [0.0, 4.0], Default: 0.01
      cursor_tuple_fraction, Type: UniformFloat, Range: [0.0, 1.0], Default: 0.1
      data_sync_retry, Type: Categorical, Choices: {on, off}, Default: off
      deadlock_timeout, Type: UniformInteger, Range: [1, 5000], Default: 1000
      default_statistics_target, Type: UniformInteger, Range: [1, 5120], Default: 100
      default_transaction_deferrable, Type: Categorical, Choices: {on, off}, Default: off
      effective_cache_size, Type: UniformInteger, Range: [1, 2097152], Default: 524288
      effective_io_concurrency, Type: UniformInteger, Range: [0, 512], Default: 1
      enable_bitmapscan, Type: Categorical, Choices: {on, off}, Default: on
      enable_hashagg, Type: Categorical, Choices: {on, off}, Default: on
      enable_hashjoin, Type: Categorical, Choices: {on, off}, Default: on
      enable_indexonlyscan, Type: Categorical, Choices: {on, off}, Default: on
      enable_indexscan, Type: Categorical, Choices: {on, off}, Default: on
      enable_material, Type: Categorical, Choices: {on, off}, Default: on
      enable_mergejoin, Type: Categorical, Choices: {on, off}, Default: on
      enable_nestloop, Type: Categorical, Choices: {on, off}, Default: on
      enable_seqscan, Type: Categorical, Choices: {on, off}, Default: on
      enable_sort, Type: Categorical, Choices: {on, off}, Default: on
      enable_tidscan, Type: Categorical, Choices: {on, off}, Default: on
      from_collapse_limit, Type: UniformInteger, Range: [1, 50], Default: 8
      full_page_writes, Type: Categorical, Choices: {on, off}, Default: on
      geqo, Type: Categorical, Choices: {on, off}, Default: on
      geqo_effort, Type: UniformInteger, Range: [1, 10], Default: 5
      geqo_generations, Type: UniformInteger, Range: [0, 1000], Default: 0
      geqo_pool_size, Type: UniformInteger, Range: [0, 1000], Default: 0
      geqo_seed, Type: UniformFloat, Range: [0.0, 1.0], Default: 0.0
      geqo_selection_bias, Type: UniformFloat, Range: [1.5, 2.0], Default: 2.0
      geqo_threshold, Type: UniformInteger, Range: [2, 50], Default: 12
      join_collapse_limit, Type: UniformInteger, Range: [1, 50], Default: 8
      maintenance_work_mem, Type: UniformInteger, Range: [1024, 1048576], Default: 65536
      max_connections, Type: UniformInteger, Range: [5, 10000], Default: 100
      max_files_per_process, Type: UniformInteger, Range: [25, 50000], Default: 1000
      max_locks_per_transaction, Type: UniformInteger, Range: [10, 1024], Default: 64
      max_parallel_workers_per_gather, Type: UniformInteger, Range: [0, 256], Default: 0
      max_pred_locks_per_transaction, Type: UniformInteger, Range: [10, 1024], Default: 64
      max_prepared_transactions, Type: UniformInteger, Range: [0, 1024], Default: 0
      max_stack_depth, Type: UniformInteger, Range: [100, 7680], Default: 100
      max_wal_size, Type: UniformInteger, Range: [2, 256], Default: 64
      max_worker_processes, Type: UniformInteger, Range: [0, 256], Default: 8
      min_parallel_relation_size, Type: UniformInteger, Range: [0, 131072], Default: 1024
      min_wal_size, Type: UniformInteger, Range: [2, 16], Default: 5
      old_snapshot_threshold, Type: UniformInteger, Range: [-1, 86400], Default: -1
      parallel_setup_cost, Type: UniformFloat, Range: [0.0, 2500.0], Default: 1000.0
      parallel_tuple_cost, Type: UniformFloat, Range: [0.0, 4.0], Default: 0.1
      quote_all_identifiers, Type: Categorical, Choices: {on, off}, Default: off
      random_page_cost, Type: UniformFloat, Range: [0.0, 8.0], Default: 4.0
      replacement_sort_tuples, Type: UniformInteger, Range: [0, 2147483647], Default: 150000
      seq_page_cost, Type: UniformFloat, Range: [0.0, 4.0], Default: 1.0
      shared_buffers, Type: UniformInteger, Range: [16, 1048576], Default: 1024
      temp_buffers, Type: UniformInteger, Range: [100, 65536], Default: 1024
      temp_file_limit, Type: UniformInteger, Range: [-1, 20971520], Default: -1
      vacuum_cost_delay, Type: UniformInteger, Range: [0, 100], Default: 0
      vacuum_cost_limit, Type: UniformInteger, Range: [1, 10000], Default: 200
      vacuum_cost_page_dirty, Type: UniformInteger, Range: [0, 10000], Default: 20
      vacuum_cost_page_hit, Type: UniformInteger, Range: [0, 10000], Default: 1
      vacuum_cost_page_miss, Type: UniformInteger, Range: [0, 10000], Default: 10
      vacuum_freeze_min_age, Type: UniformInteger, Range: [0, 1000000000], Default: 50000000
      vacuum_freeze_table_age, Type: UniformInteger, Range: [0, 2000000000], Default: 150000000
      vacuum_multixact_freeze_min_age, Type: UniformInteger, Range: [0, 1000000000], Default: 5000000
      vacuum_multixact_freeze_table_age, Type: UniformInteger, Range: [0, 2000000000], Default: 150000000
      wal_buffers, Type: UniformInteger, Range: [-1, 65536], Default: -1
      wal_compression, Type: Categorical, Choices: {on, off}, Default: off
      wal_log_hints, Type: Categorical, Choices: {on, off}, Default: off
      wal_writer_delay, Type: UniformInteger, Range: [1, 4096], Default: 200
      wal_writer_flush_after, Type: UniformInteger, Range: [0, 32768], Default: 128
      work_mem, Type: UniformInteger, Range: [64, 262144], Default: 4096

  INFO:smac.utils.io.cmd_reader.CMDReader:Output to results/ycsb.workloada/seed1
  INFO:smac.facade.smac_hpo_facade.SMAC4HPO:Optimizing a deterministic scenario for quality without a tuner timeout - will make SMAC deterministic and only evaluate one configuration per iteration!
  INFO:adapters.bias_sampling.LHDesignWithBiasedSampling:Running initial design for 10 configurations
  INFO:smac.facade.smac_hpo_facade.SMAC4HPO:<class 'smac.facade.smac_hpo_facade.SMAC4HPO'>
  INFO:root:<smac.facade.smac_hpo_facade.SMAC4HPO object at 0x7f4660f19d60>
  INFO:root:Evaluating Default Configuration
  INFO:root:

  ========================= Iteration  0 =========================


  INFO:root:Sample from optimizer:
  INFO:root:Configuration:
    autovacuum, Value: 'on'
    autovacuum_analyze_scale_factor, Value: 0.1
    autovacuum_analyze_threshold, Value: 50
    autovacuum_freeze_max_age, Value: 200000000
    autovacuum_max_workers, Value: 3
    autovacuum_multixact_freeze_max_age, Value: 400000000
    autovacuum_naptime, Value: 60
    autovacuum_vacuum_cost_delay, Value: 20
    autovacuum_vacuum_cost_limit, Value: -1
    autovacuum_vacuum_scale_factor, Value: 0.2
    autovacuum_vacuum_threshold, Value: 50
    autovacuum_work_mem, Value: -1
    backend_flush_after, Value: 0
    bgwriter_delay, Value: 200
    bgwriter_flush_after, Value: 64
    bgwriter_lru_maxpages, Value: 100
    bgwriter_lru_multiplier, Value: 2.0
    checkpoint_completion_target, Value: 0.5
    checkpoint_flush_after, Value: 32
    checkpoint_timeout, Value: 300
    commit_delay, Value: 0
    commit_siblings, Value: 5
    cpu_index_tuple_cost, Value: 0.005
    cpu_operator_cost, Value: 0.0025
    cpu_tuple_cost, Value: 0.01
    cursor_tuple_fraction, Value: 0.1
    data_sync_retry, Value: 'off'
    deadlock_timeout, Value: 1000
    default_statistics_target, Value: 100
    default_transaction_deferrable, Value: 'off'
    effective_cache_size, Value: 524288
    effective_io_concurrency, Value: 1
    enable_bitmapscan, Value: 'on'
    enable_hashagg, Value: 'on'
    enable_hashjoin, Value: 'on'
    enable_indexonlyscan, Value: 'on'
    enable_indexscan, Value: 'on'
    enable_material, Value: 'on'
    enable_mergejoin, Value: 'on'
    enable_nestloop, Value: 'on'
    enable_seqscan, Value: 'on'
    enable_sort, Value: 'on'
    enable_tidscan, Value: 'on'
    from_collapse_limit, Value: 8
    full_page_writes, Value: 'on'
    geqo, Value: 'on'
    geqo_effort, Value: 5
    geqo_generations, Value: 0
    geqo_pool_size, Value: 0
    geqo_seed, Value: 0.0
    geqo_selection_bias, Value: 2.0
    geqo_threshold, Value: 12
    join_collapse_limit, Value: 8
    maintenance_work_mem, Value: 65536
    max_connections, Value: 100
    max_files_per_process, Value: 1000
    max_locks_per_transaction, Value: 64
    max_parallel_workers_per_gather, Value: 0
    max_pred_locks_per_transaction, Value: 64
    max_prepared_transactions, Value: 0
    max_stack_depth, Value: 100
    max_wal_size, Value: 64
    max_worker_processes, Value: 8
    min_parallel_relation_size, Value: 1024
    min_wal_size, Value: 5
    old_snapshot_threshold, Value: -1
    parallel_setup_cost, Value: 1000.0
    parallel_tuple_cost, Value: 0.1
    quote_all_identifiers, Value: 'off'
    random_page_cost, Value: 4.0
    replacement_sort_tuples, Value: 150000
    seq_page_cost, Value: 1.0
    shared_buffers, Value: 1024
    temp_buffers, Value: 1024
    temp_file_limit, Value: -1
    vacuum_cost_delay, Value: 0
    vacuum_cost_limit, Value: 200
    vacuum_cost_page_dirty, Value: 20
    vacuum_cost_page_hit, Value: 1
    vacuum_cost_page_miss, Value: 10
    vacuum_freeze_min_age, Value: 50000000
    vacuum_freeze_table_age, Value: 150000000
    vacuum_multixact_freeze_min_age, Value: 5000000
    vacuum_multixact_freeze_table_age, Value: 150000000
    wal_buffers, Value: -1
    wal_compression, Value: 'off'
    wal_log_hints, Value: 'off'
    wal_writer_delay, Value: 200
    wal_writer_flush_after, Value: 128
    work_mem, Value: 4096

  INFO:root:Evaluating Configuration:
  {'autovacuum': 'on', 'autovacuum_analyze_scale_factor': 0.1, 'autovacuum_analyze_threshold': 50, 'autovacuum_freeze_max_age': 200000000, 'autovacuum_max_workers': 3, 'autovacuum_multixact_freeze_max_age': 400000000, 'autovacuum_naptime': 60, 'autovacuum_vacuum_cost_delay': 20, 'autovacuum_vacuum_cost_limit': -1, 'autovacuum_vacuum_scale_factor': 0.2, 'autovacuum_vacuum_threshold': 50, 'autovacuum_work_mem': -1, 'backend_flush_after': 0, 'bgwriter_delay': 200, 'bgwriter_flush_after': 64, 'bgwriter_lru_maxpages': 100, 'bgwriter_lru_multiplier': 2.0, 'checkpoint_completion_target': 0.5, 'checkpoint_flush_after': 32, 'checkpoint_timeout': 300, 'commit_delay': 0, 'commit_siblings': 5, 'cpu_index_tuple_cost': 0.01, 'cpu_operator_cost': 0.0, 'cpu_tuple_cost': 0.01, 'cursor_tuple_fraction': 0.1, 'data_sync_retry': 'off', 'deadlock_timeout': 1000, 'default_statistics_target': 100, 'default_transaction_deferrable': 'off', 'effective_cache_size': 524288, 'effective_io_concurrency': 1, 'enable_bitmapscan': 'on', 'enable_hashagg': 'on', 'enable_hashjoin': 'on', 'enable_indexonlyscan': 'on', 'enable_indexscan': 'on', 'enable_material': 'on', 'enable_mergejoin': 'on', 'enable_nestloop': 'on', 'enable_seqscan': 'on', 'enable_sort': 'on', 'enable_tidscan': 'on', 'from_collapse_limit': 8, 'full_page_writes': 'on', 'geqo': 'on', 'geqo_effort': 5, 'geqo_generations': 0, 'geqo_pool_size': 0, 'geqo_seed': 0.0, 'geqo_selection_bias': 2.0, 'geqo_threshold': 12, 'join_collapse_limit': 8, 'maintenance_work_mem': 65536, 'max_connections': 100, 'max_files_per_process': 1000, 'max_locks_per_transaction': 64, 'max_parallel_workers_per_gather': 0, 'max_pred_locks_per_transaction': 64, 'max_prepared_transactions': 0, 'max_stack_depth': 100, 'max_wal_size': 64, 'max_worker_processes': 8, 'min_parallel_relation_size': 1024, 'min_wal_size': 5, 'old_snapshot_threshold': -1, 'parallel_setup_cost': 1000.0, 'parallel_tuple_cost': 0.1, 'quote_all_identifiers': 'off', 'random_page_cost': 4.0, 'replacement_sort_tuples': 150000, 'seq_page_cost': 1.0, 'shared_buffers': 1024, 'temp_buffers': 1024, 'temp_file_limit': -1, 'vacuum_cost_delay': 0, 'vacuum_cost_limit': 200, 'vacuum_cost_page_dirty': 20, 'vacuum_cost_page_hit': 1, 'vacuum_cost_page_miss': 10, 'vacuum_freeze_min_age': 50000000, 'vacuum_freeze_table_age': 150000000, 'vacuum_multixact_freeze_min_age': 5000000, 'vacuum_multixact_freeze_table_age': 150000000, 'wal_buffers': -1, 'wal_compression': 'off', 'wal_log_hints': 'off', 'wal_writer_delay': 200, 'wal_writer_flush_after': 128, 'work_mem': 4096}
  INFO:root:Performance Statistics:
  {'throughput': 3201.0, 'latency': 2033.0, 'runtime': 0}
  INFO:root:Evaluation took 0 seconds
  INFO:root:Throughput: 3201.0 ops/sec
  INFO:smac.optimizer.smbo.SMBO:Running initial design
  INFO:smac.intensification.intensification.Intensifier:First run, no incumbent provided; challenger is assumed to be the incumbent
  INFO:root:

  ========================= Iteration  1 =========================


  INFO:root:Sample from optimizer:
  INFO:root:Configuration:
    autovacuum, Value: 'on'
    autovacuum_analyze_scale_factor, Value: 39.840721149514835
    autovacuum_analyze_threshold, Value: 423
    autovacuum_freeze_max_age, Value: 1137928421
    autovacuum_max_workers, Value: 9865
    autovacuum_multixact_freeze_max_age, Value: 501682190
    autovacuum_naptime, Value: 179914
    autovacuum_vacuum_cost_delay, Value: 79
    autovacuum_vacuum_cost_limit, Value: 7140
    autovacuum_vacuum_scale_factor, Value: 50.512112558630776
    autovacuum_vacuum_threshold, Value: 1036745380
    autovacuum_work_mem, Value: 241078
    backend_flush_after, Value: 41
    bgwriter_delay, Value: 1511
    bgwriter_flush_after, Value: 224
    bgwriter_lru_maxpages, Value: 710
    bgwriter_lru_multiplier, Value: 3.9684511106415465
    checkpoint_completion_target, Value: 0.6307357933221851
    checkpoint_flush_after, Value: 37
    checkpoint_timeout, Value: 51380
    commit_delay, Value: 1210
    commit_siblings, Value: 9
    cpu_index_tuple_cost, Value: 1.7931577158789112
    cpu_operator_cost, Value: 0.417550540642205
    cpu_tuple_cost, Value: 2.000874954706705
    cursor_tuple_fraction, Value: 0.565098284033256
    data_sync_retry, Value: 'on'
    deadlock_timeout, Value: 2403
    default_statistics_target, Value: 4100
    default_transaction_deferrable, Value: 'on'
    effective_cache_size, Value: 1515239
    effective_io_concurrency, Value: 165
    enable_bitmapscan, Value: 'on'
    enable_hashagg, Value: 'off'
    enable_hashjoin, Value: 'off'
    enable_indexonlyscan, Value: 'on'
    enable_indexscan, Value: 'on'
    enable_material, Value: 'off'
    enable_mergejoin, Value: 'off'
    enable_nestloop, Value: 'on'
    enable_seqscan, Value: 'off'
    enable_sort, Value: 'on'
    enable_tidscan, Value: 'on'
    from_collapse_limit, Value: 34
    full_page_writes, Value: 'on'
    geqo, Value: 'off'
    geqo_effort, Value: 6
    geqo_generations, Value: 769
    geqo_pool_size, Value: 774
    geqo_seed, Value: 0.4334145502255084
    geqo_selection_bias, Value: 1.8527977503494228
    geqo_threshold, Value: 17
    join_collapse_limit, Value: 11
    maintenance_work_mem, Value: 963228
    max_connections, Value: 3370
    max_files_per_process, Value: 4584
    max_locks_per_transaction, Value: 231
    max_parallel_workers_per_gather, Value: 123
    max_pred_locks_per_transaction, Value: 1000
    max_prepared_transactions, Value: 336
    max_stack_depth, Value: 904
    max_wal_size, Value: 240
    max_worker_processes, Value: 129
    min_parallel_relation_size, Value: 2580
    min_wal_size, Value: 13
    old_snapshot_threshold, Value: 6649
    parallel_setup_cost, Value: 1957.9604286866424
    parallel_tuple_cost, Value: 3.260321293160249
    quote_all_identifiers, Value: 'off'
    random_page_cost, Value: 3.949971690623953
    replacement_sort_tuples, Value: 1935771376
    seq_page_cost, Value: 0.6241110283938495
    shared_buffers, Value: 52147
    temp_buffers, Value: 40725
    temp_file_limit, Value: 14261387
    vacuum_cost_delay, Value: 80
    vacuum_cost_limit, Value: 7490
    vacuum_cost_page_dirty, Value: 3568
    vacuum_cost_page_hit, Value: 783
    vacuum_cost_page_miss, Value: 6206
    vacuum_freeze_min_age, Value: 311915929
    vacuum_freeze_table_age, Value: 178773595
    vacuum_multixact_freeze_min_age, Value: 485722870
    vacuum_multixact_freeze_table_age, Value: 1197874334
    wal_buffers, Value: 26550
    wal_compression, Value: 'off'
    wal_log_hints, Value: 'on'
    wal_writer_delay, Value: 2593
    wal_writer_flush_after, Value: 4567
    work_mem, Value: 167222

  INFO:root:Evaluating Configuration:
  {'autovacuum': 'on', 'autovacuum_analyze_scale_factor': 39.84, 'autovacuum_analyze_threshold': 423, 'autovacuum_freeze_max_age': 1137928421, 'autovacuum_max_workers': 9865, 'autovacuum_multixact_freeze_max_age': 501682190, 'autovacuum_naptime': 179914, 'autovacuum_vacuum_cost_delay': 79, 'autovacuum_vacuum_cost_limit': 7140, 'autovacuum_vacuum_scale_factor': 50.51, 'autovacuum_vacuum_threshold': 1036745380, 'autovacuum_work_mem': 241078, 'backend_flush_after': 41, 'bgwriter_delay': 1511, 'bgwriter_flush_after': 224, 'bgwriter_lru_maxpages': 710, 'bgwriter_lru_multiplier': 3.97, 'checkpoint_completion_target': 0.63, 'checkpoint_flush_after': 37, 'checkpoint_timeout': 51380, 'commit_delay': 1210, 'commit_siblings': 9, 'cpu_index_tuple_cost': 1.79, 'cpu_operator_cost': 0.42, 'cpu_tuple_cost': 2.0, 'cursor_tuple_fraction': 0.57, 'data_sync_retry': 'on', 'deadlock_timeout': 2403, 'default_statistics_target': 4100, 'default_transaction_deferrable': 'on', 'effective_cache_size': 1515239, 'effective_io_concurrency': 165, 'enable_bitmapscan': 'on', 'enable_hashagg': 'off', 'enable_hashjoin': 'off', 'enable_indexonlyscan': 'on', 'enable_indexscan': 'on', 'enable_material': 'off', 'enable_mergejoin': 'off', 'enable_nestloop': 'on', 'enable_seqscan': 'off', 'enable_sort': 'on', 'enable_tidscan': 'on', 'from_collapse_limit': 34, 'full_page_writes': 'on', 'geqo': 'off', 'geqo_effort': 6, 'geqo_generations': 769, 'geqo_pool_size': 774, 'geqo_seed': 0.43, 'geqo_selection_bias': 1.85, 'geqo_threshold': 17, 'join_collapse_limit': 11, 'maintenance_work_mem': 963228, 'max_connections': 3370, 'max_files_per_process': 4584, 'max_locks_per_transaction': 231, 'max_parallel_workers_per_gather': 123, 'max_pred_locks_per_transaction': 1000, 'max_prepared_transactions': 336, 'max_stack_depth': 904, 'max_wal_size': 240, 'max_worker_processes': 129, 'min_parallel_relation_size': 2580, 'min_wal_size': 13, 'old_snapshot_threshold': 6649, 'parallel_setup_cost': 1957.96, 'parallel_tuple_cost': 3.26, 'quote_all_identifiers': 'off', 'random_page_cost': 3.95, 'replacement_sort_tuples': 1935771376, 'seq_page_cost': 0.62, 'shared_buffers': 52147, 'temp_buffers': 40725, 'temp_file_limit': 14261387, 'vacuum_cost_delay': 80, 'vacuum_cost_limit': 7490, 'vacuum_cost_page_dirty': 3568, 'vacuum_cost_page_hit': 783, 'vacuum_cost_page_miss': 6206, 'vacuum_freeze_min_age': 311915929, 'vacuum_freeze_table_age': 178773595, 'vacuum_multixact_freeze_min_age': 485722870, 'vacuum_multixact_freeze_table_age': 1197874334, 'wal_buffers': 26550, 'wal_compression': 'off', 'wal_log_hints': 'on', 'wal_writer_delay': 2593, 'wal_writer_flush_after': 4567, 'work_mem': 167222}
  INFO:root:Performance Statistics:
  {'throughput': 5179.0, 'latency': 2931.0, 'runtime': 0}
  INFO:root:Evaluation took 0 seconds
  INFO:root:Throughput: 5179.0 ops/sec
  INFO:smac.intensification.intensification.Intensifier:First run, no incumbent provided; challenger is assumed to be the incumbent
  INFO:smac.intensification.intensification.Intensifier:Updated estimated cost of incumbent on 1 runs: -5179.0000
  INFO:root:

  ========================= Iteration  2 =========================
  ...
  ```

</details>

<br/>

Similarly, one can run the other workloads:

```bash
python3 run-smac.py configs/ycsb/ycsbB/ycsbB.all.ini 1
python3 run-smac.py configs/benchbase/tpcc/tpcc.all.ini 1
python3 run-smac.py configs/benchbase/seats/seats.all.ini 1
python3 run-smac.py configs/benchbase/twitter/twitter.all.ini 1
python3 run-smac.py configs/benchbase/resourcestresser/resourcestresser.all.ini 1
```

***

To employ LlamaTune's search space transformations, while using SMAC as the underlying optimizer, the following configuration file should be used:

```bash
python3 run-smac.py configs/ycsb/ycsbA/ycsbA.all.llama.ini 1
```

<details>
<summary> Example Output </summary>

```sh
INFO:root:Results will be saved @ "results/ycsb.workloada/seed1"


INFO:root:Constructing new optimizer...
INFO:root:Run History: None
INFO:root:Ignored knobs: None
INFO:adapters.configspace.low_embeddings:Using quantization: q=10000
INFO:adapters.configspace.low_embeddings:Configuration space object:
  Hyperparameters:
input
    hesbo_0, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_1, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_10, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_11, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_12, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_13, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_14, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_15, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_2, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_3, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_4, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_5, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_6, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_7, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_8, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_9, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002

INFO:root:
input space:
Configuration space object:
  Hyperparameters:
input
    hesbo_0, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_1, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_10, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_11, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_12, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_13, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_14, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_15, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_2, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_3, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_4, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_5, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_6, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_7, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_8, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002
    hesbo_9, Type: UniformFloat, Range: [-1.0, 1.0], Default: 0.0, Q: 0.0002

INFO:smac.utils.io.cmd_reader.CMDReader:Output to results/ycsb.workloada/seed1
INFO:smac.facade.smac_hpo_facade.SMAC4HPO:Optimizing a deterministic scenario for quality without a tuner timeout - will make SMAC deterministic and only evaluate one configuration per iteration!
INFO:adapters.bias_sampling.LHDesignWithBiasedSampling:Running initial design for 10 configurations
INFO:smac.facade.smac_hpo_facade.SMAC4HPO:<class 'smac.facade.smac_hpo_facade.SMAC4HPO'>
INFO:root:<smac.facade.smac_hpo_facade.SMAC4HPO object at 0x7f67abe33f70>
INFO:root:Evaluating Default Configuration
INFO:root:

========================= Iteration  0 =========================


INFO:root:Sample from optimizer:
INFO:root:Configuration:
  autovacuum, Value: 'on'
  autovacuum_analyze_scale_factor, Value: 0.1
  autovacuum_analyze_threshold, Value: 50
  autovacuum_freeze_max_age, Value: 200000000
  autovacuum_max_workers, Value: 3
  autovacuum_multixact_freeze_max_age, Value: 400000000
  autovacuum_naptime, Value: 60
  autovacuum_vacuum_cost_delay, Value: 20
  autovacuum_vacuum_cost_limit, Value: -1
  autovacuum_vacuum_scale_factor, Value: 0.2
  autovacuum_vacuum_threshold, Value: 50
  autovacuum_work_mem, Value: -1
  backend_flush_after, Value: 0
  bgwriter_delay, Value: 200
  bgwriter_flush_after, Value: 64
  bgwriter_lru_maxpages, Value: 100
  bgwriter_lru_multiplier, Value: 2.0
  checkpoint_completion_target, Value: 0.5
  checkpoint_flush_after, Value: 32
  checkpoint_timeout, Value: 300
  commit_delay, Value: 0
  commit_siblings, Value: 5
  cpu_index_tuple_cost, Value: 0.005
  cpu_operator_cost, Value: 0.0025
  cpu_tuple_cost, Value: 0.01
  cursor_tuple_fraction, Value: 0.1
  data_sync_retry, Value: 'off'
  deadlock_timeout, Value: 1000
  default_statistics_target, Value: 100
  default_transaction_deferrable, Value: 'off'
  effective_cache_size, Value: 524288
  effective_io_concurrency, Value: 1
  enable_bitmapscan, Value: 'on'
  enable_hashagg, Value: 'on'
  enable_hashjoin, Value: 'on'
  enable_indexonlyscan, Value: 'on'
  enable_indexscan, Value: 'on'
  enable_material, Value: 'on'
  enable_mergejoin, Value: 'on'
  enable_nestloop, Value: 'on'
  enable_seqscan, Value: 'on'
  enable_sort, Value: 'on'
  enable_tidscan, Value: 'on'
  from_collapse_limit, Value: 8
  full_page_writes, Value: 'on'
  geqo, Value: 'on'
  geqo_effort, Value: 5
  geqo_generations, Value: 0
  geqo_pool_size, Value: 0
  geqo_seed, Value: 0.0
  geqo_selection_bias, Value: 2.0
  geqo_threshold, Value: 12
  join_collapse_limit, Value: 8
  maintenance_work_mem, Value: 65536
  max_connections, Value: 100
  max_files_per_process, Value: 1000
  max_locks_per_transaction, Value: 64
  max_parallel_workers_per_gather, Value: 0
  max_pred_locks_per_transaction, Value: 64
  max_prepared_transactions, Value: 0
  max_stack_depth, Value: 100
  max_wal_size, Value: 64
  max_worker_processes, Value: 8
  min_parallel_relation_size, Value: 1024
  min_wal_size, Value: 5
  old_snapshot_threshold, Value: -1
  parallel_setup_cost, Value: 1000.0
  parallel_tuple_cost, Value: 0.1
  quote_all_identifiers, Value: 'off'
  random_page_cost, Value: 4.0
  replacement_sort_tuples, Value: 150000
  seq_page_cost, Value: 1.0
  shared_buffers, Value: 1024
  temp_buffers, Value: 1024
  temp_file_limit, Value: -1
  vacuum_cost_delay, Value: 0
  vacuum_cost_limit, Value: 200
  vacuum_cost_page_dirty, Value: 20
  vacuum_cost_page_hit, Value: 1
  vacuum_cost_page_miss, Value: 10
  vacuum_freeze_min_age, Value: 50000000
  vacuum_freeze_table_age, Value: 150000000
  vacuum_multixact_freeze_min_age, Value: 5000000
  vacuum_multixact_freeze_table_age, Value: 150000000
  wal_buffers, Value: -1
  wal_compression, Value: 'off'
  wal_log_hints, Value: 'off'
  wal_writer_delay, Value: 200
  wal_writer_flush_after, Value: 128
  work_mem, Value: 4096

INFO:root:Evaluating Configuration:
{'autovacuum': 'on', 'autovacuum_analyze_scale_factor': 0.1, 'autovacuum_analyze_threshold': 50, 'autovacuum_freeze_max_age': 200000000, 'autovacuum_max_workers': 3, 'autovacuum_multixact_freeze_max_age': 400000000, 'autovacuum_naptime': 60, 'autovacuum_vacuum_cost_delay': 20, 'autovacuum_vacuum_cost_limit': -1, 'autovacuum_vacuum_scale_factor': 0.2, 'autovacuum_vacuum_threshold': 50, 'autovacuum_work_mem': -1, 'backend_flush_after': 0, 'bgwriter_delay': 200, 'bgwriter_flush_after': 64, 'bgwriter_lru_maxpages': 100, 'bgwriter_lru_multiplier': 2.0, 'checkpoint_completion_target': 0.5, 'checkpoint_flush_after': 32, 'checkpoint_timeout': 300, 'commit_delay': 0, 'commit_siblings': 5, 'cpu_index_tuple_cost': 0.01, 'cpu_operator_cost': 0.0, 'cpu_tuple_cost': 0.01, 'cursor_tuple_fraction': 0.1, 'data_sync_retry': 'off', 'deadlock_timeout': 1000, 'default_statistics_target': 100, 'default_transaction_deferrable': 'off', 'effective_cache_size': 524288, 'effective_io_concurrency': 1, 'enable_bitmapscan': 'on', 'enable_hashagg': 'on', 'enable_hashjoin': 'on', 'enable_indexonlyscan': 'on', 'enable_indexscan': 'on', 'enable_material': 'on', 'enable_mergejoin': 'on', 'enable_nestloop': 'on', 'enable_seqscan': 'on', 'enable_sort': 'on', 'enable_tidscan': 'on', 'from_collapse_limit': 8, 'full_page_writes': 'on', 'geqo': 'on', 'geqo_effort': 5, 'geqo_generations': 0, 'geqo_pool_size': 0, 'geqo_seed': 0.0, 'geqo_selection_bias': 2.0, 'geqo_threshold': 12, 'join_collapse_limit': 8, 'maintenance_work_mem': 65536, 'max_connections': 100, 'max_files_per_process': 1000, 'max_locks_per_transaction': 64, 'max_parallel_workers_per_gather': 0, 'max_pred_locks_per_transaction': 64, 'max_prepared_transactions': 0, 'max_stack_depth': 100, 'max_wal_size': 64, 'max_worker_processes': 8, 'min_parallel_relation_size': 1024, 'min_wal_size': 5, 'old_snapshot_threshold': -1, 'parallel_setup_cost': 1000.0, 'parallel_tuple_cost': 0.1, 'quote_all_identifiers': 'off', 'random_page_cost': 4.0, 'replacement_sort_tuples': 150000, 'seq_page_cost': 1.0, 'shared_buffers': 1024, 'temp_buffers': 1024, 'temp_file_limit': -1, 'vacuum_cost_delay': 0, 'vacuum_cost_limit': 200, 'vacuum_cost_page_dirty': 20, 'vacuum_cost_page_hit': 1, 'vacuum_cost_page_miss': 10, 'vacuum_freeze_min_age': 50000000, 'vacuum_freeze_table_age': 150000000, 'vacuum_multixact_freeze_min_age': 5000000, 'vacuum_multixact_freeze_table_age': 150000000, 'wal_buffers': -1, 'wal_compression': 'off', 'wal_log_hints': 'off', 'wal_writer_delay': 200, 'wal_writer_flush_after': 128, 'work_mem': 4096}
INFO:root:Performance Statistics:
{'throughput': 3201.0, 'latency': 2033.0, 'runtime': 0}
INFO:root:Evaluation took 0 seconds
INFO:root:Throughput: 3201.0 ops/sec
INFO:smac.optimizer.smbo.SMBO:Running initial design
INFO:smac.intensification.intensification.Intensifier:First run, no incumbent provided; challenger is assumed to be the incumbent
INFO:root:

========================= Iteration  1 =========================


INFO:root:Sample from optimizer:
INFO:root:Configuration:
  hesbo_0, Value: -0.48739999999999994
  hesbo_1, Value: -0.6033999999999999
  hesbo_10, Value: 0.04700000000000015
  hesbo_11, Value: 0.13780000000000014
  hesbo_12, Value: 0.3728
  hesbo_13, Value: -0.6983999999999999
  hesbo_14, Value: 0.36740000000000017
  hesbo_15, Value: 0.7842
  hesbo_2, Value: 0.2278
  hesbo_3, Value: 0.8102
  hesbo_4, Value: -0.4346
  hesbo_5, Value: 0.059800000000000075
  hesbo_6, Value: -0.6788
  hesbo_7, Value: -0.24759999999999993
  hesbo_8, Value: -0.25139999999999996
  hesbo_9, Value: 0.4192

INFO:root:Evaluating Configuration:
{'autovacuum': 'on', 'autovacuum_analyze_scale_factor': 43.11, 'autovacuum_analyze_threshold': 687, 'autovacuum_freeze_max_age': 748662570, 'autovacuum_max_workers': 8921, 'autovacuum_multixact_freeze_max_age': 580807096, 'autovacuum_naptime': 1221704, 'autovacuum_vacuum_cost_delay': 41, 'autovacuum_vacuum_cost_limit': -1, 'autovacuum_vacuum_scale_factor': 25.63, 'autovacuum_vacuum_threshold': 550400058, 'autovacuum_work_mem': -1, 'backend_flush_after': 156, 'bgwriter_delay': 2499, 'bgwriter_flush_after': 208, 'bgwriter_lru_maxpages': 142, 'bgwriter_lru_multiplier': 6.72, 'checkpoint_completion_target': 0.29, 'checkpoint_flush_after': 132, 'checkpoint_timeout': 24447, 'commit_delay': 2801, 'commit_siblings': 9, 'cpu_index_tuple_cost': 2.46, 'cpu_operator_cost': 1.13, 'cpu_tuple_cost': 2.28, 'cursor_tuple_fraction': 0.31, 'data_sync_retry': 'on', 'deadlock_timeout': 1569, 'default_statistics_target': 4348, 'default_transaction_deferrable': 'on', 'effective_cache_size': 809711, 'effective_io_concurrency': 53, 'enable_bitmapscan': 'on', 'enable_hashagg': 'on', 'enable_hashjoin': 'off', 'enable_indexonlyscan': 'on', 'enable_indexscan': 'on', 'enable_material': 'on', 'enable_mergejoin': 'off', 'enable_nestloop': 'on', 'enable_seqscan': 'on', 'enable_sort': 'on', 'enable_tidscan': 'on', 'from_collapse_limit': 19, 'full_page_writes': 'on', 'geqo': 'off', 'geqo_effort': 9, 'geqo_generations': 637, 'geqo_pool_size': 0, 'geqo_seed': 0.26, 'geqo_selection_bias': 1.84, 'geqo_threshold': 11, 'join_collapse_limit': 32, 'maintenance_work_mem': 393123, 'max_connections': 8493, 'max_files_per_process': 45258, 'max_locks_per_transaction': 119, 'max_parallel_workers_per_gather': 88, 'max_pred_locks_per_transaction': 304, 'max_prepared_transactions': 223, 'max_stack_depth': 5283, 'max_wal_size': 97, 'max_worker_processes': 24, 'min_parallel_relation_size': 21050, 'min_wal_size': 9, 'old_snapshot_threshold': 64984, 'parallel_setup_cost': 726.0, 'parallel_tuple_cost': 0.38, 'quote_all_identifiers': 'on', 'random_page_cost': 5.01, 'replacement_sort_tuples': 425846007, 'seq_page_cost': 1.72, 'shared_buffers': 719748, 'temp_buffers': 34356, 'temp_file_limit': 2167930, 'vacuum_cost_delay': 68, 'vacuum_cost_limit': 8492, 'vacuum_cost_page_dirty': 949, 'vacuum_cost_page_hit': 2904, 'vacuum_cost_page_miss': 3861, 'vacuum_freeze_min_age': 107900000, 'vacuum_freeze_table_age': 512600000, 'vacuum_multixact_freeze_min_age': 717300000, 'vacuum_multixact_freeze_table_age': 580800000, 'wal_buffers': 56697, 'wal_compression': 'on', 'wal_log_hints': 'off', 'wal_writer_delay': 1541, 'wal_writer_flush_after': 13250, 'work_mem': 76172}
INFO:root:Performance Statistics:
{'throughput': 5179.0, 'latency': 2931.0, 'runtime': 0}
INFO:root:Evaluation took 0 seconds
INFO:root:Throughput: 5179.0 ops/sec
INFO:smac.intensification.intensification.Intensifier:First run, no incumbent provided; challenger is assumed to be the incumbent
INFO:smac.intensification.intensification.Intensifier:Updated estimated cost of incumbent on 1 runs: -5179.0000
INFO:root:

========================= Iteration  2 =========================
...
```
</details>

<br/>

Again, the other workloads can be run using:
```bash
python3 run-smac.py configs/ycsb/ycsbB/ycsbB.all.llama.ini 1
python3 run-smac.py configs/benchbase/tpcc/tpcc.all.llama.ini 1
python3 run-smac.py configs/benchbase/seats/seats.all.llama.ini 1
python3 run-smac.py configs/benchbase/twitter/twitter.all.llama.ini 1
python3 run-smac.py configs/benchbase/resourcestresser/resourcestresser.all.llama.ini 1
```

***

**NOTE:** that one can also use the RL-based optimizer (i.e., DDPG) by replacing `run-smac.py` with `run-ddpg.py`.

As noted above, these commands only output the configurations suggested by the optimizers, and do not actually execute any workload on the DBMS.
