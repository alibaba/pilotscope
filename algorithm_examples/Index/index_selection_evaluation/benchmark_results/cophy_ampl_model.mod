set QUERIES;
param NUMBER_OF_INDEXES integer;
param NUMBER_OF_INDEX_COMBINATIONS integer;

set INDEXES = 1 .. NUMBER_OF_INDEXES;
# 0 represents no index
set COMBINATIONS = 0 .. NUMBER_OF_INDEX_COMBINATIONS;

param storage_budget;

set indexes_per_combination {COMBINATIONS};

param size {INDEXES}; # size of index
param costs {QUERIES, COMBINATIONS} default 99999999999999; # costs of combination for query

var x {INDEXES} binary; # index is created
var y {COMBINATIONS} binary; # combination is applicable
var z {COMBINATIONS, QUERIES} binary; # combination is used for query


minimize overall_costs_of_queries: sum {c in COMBINATIONS, q in QUERIES} costs[q, c] * z[c, q];

subject to one_combination_per_query {q in QUERIES}: 1 = sum {c in COMBINATIONS} z[c, q];
subject to applicable_combination {c in COMBINATIONS}: sum {i in indexes_per_combination[c]} x[i] >= card(indexes_per_combination[c]) * y[c];
subject to usable_combination {c in COMBINATIONS, q in QUERIES}: z[c, q] <= y[c];
subject to memory_consumption: sum {i in INDEXES} x[i] * size[i] <= storage_budget;
