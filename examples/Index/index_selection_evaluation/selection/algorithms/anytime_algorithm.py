import itertools
import logging
import math
import time

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.index import Index, index_merge
from selection.selection_algorithm import DEFAULT_PARAMETER_VALUES, SelectionAlgorithm
from selection.utils import get_utilized_indexes, indexes_by_table, mb_to_b

# budget_MB: The algorithm can utilize the specified storage budget in MB.
# max_index_width: The number of columns an index can contain at maximum.
# max_runtime_minutes: The algorithm is stopped either if all seeds are evaluated or
#                      when max_runtime_minutes is exceeded. Whatever happens first.
#                      In case of the latter, the current best solution is returned.
DEFAULT_PARAMETERS = {
    "budget_MB": DEFAULT_PARAMETER_VALUES["budget_MB"],
    "max_index_width": DEFAULT_PARAMETER_VALUES["max_index_width"],
    "max_runtime_minutes": 10,
}


# This algorithm is related to the DTA Anytime algorithm employed in SQL server.
# Details of the current version of the original algorithm are not published yet.
# See the documentation for a general description:
# https://docs.microsoft.com/de-de/sql/tools/dta/dta-utility?view=sql-server-ver15
#
# Please note, that this implementation does not reflect the behavior and performance
# of the original algorithm, which might be continuously enhanced and optimized.
class AnytimeAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(
            self, database_connector, parameters, DEFAULT_PARAMETERS
        )
        self.disk_constraint = mb_to_b(self.parameters["budget_MB"])
        self.max_index_width = self.parameters["max_index_width"]
        self.max_runtime_minutes = self.parameters["max_runtime_minutes"]

    def _calculate_best_indexes(self, workload):
        logging.info("Calculating best indexes Anytime")

        # Generate syntactically relevant candidates
        candidates = candidates_per_query(
            workload,
            self.parameters["max_index_width"],
            candidate_generator=syntactically_relevant_indexes,
        )

        # Obtain best (utilized) indexes per query
        candidates, _ = get_utilized_indexes(workload, candidates, self.cost_evaluation)

        self._add_merged_indexes(candidates)

        # Remove candidates that cannot meet budget requirements
        seeds = []
        filtered_candidates = set()
        for candidate in candidates:
            if candidate.estimated_size > self.disk_constraint:
                continue

            seeds.append({candidate})
            filtered_candidates.add(candidate)

        # For reproducible results, we sort the seeds and candidates
        seeds = sorted(seeds, key=lambda candidate: candidate)
        filtered_candidates = set(
            sorted(filtered_candidates, key=lambda candidate: candidate)
        )

        seeds.append(set())
        candidates = filtered_candidates

        start_time = time.time()
        best_configuration = (None, None)
        for i, seed in enumerate(seeds):
            logging.info(f"Seed {i + 1} from {len(seeds)}")
            candidates_copy = candidates.copy()
            candidates_copy -= seed
            current_costs = self._simulate_and_evaluate_cost(workload, seed)
            indexes, costs = self.enumerate_greedy(
                workload, seed, current_costs, candidates_copy, math.inf
            )
            if best_configuration[0] is None or costs < best_configuration[1]:
                best_configuration = (indexes, costs)

            current_time = time.time()
            consumed_time = current_time - start_time
            if consumed_time > self.max_runtime_minutes * 60:
                logging.info(
                    f"Stopping after {i + 1} seeds because of timing constraints."
                )
                break
            else:
                logging.debug(
                    f"Current best: {best_configuration[1]} after {consumed_time}s."
                )

        indexes = best_configuration[0]
        return list(indexes)

    def _add_merged_indexes(self, indexes):
        index_table_dict = indexes_by_table(indexes)
        for table in index_table_dict:
            for index1, index2 in itertools.permutations(index_table_dict[table], 2):
                merged_index = index_merge(index1, index2)
                if len(merged_index.columns) > self.max_index_width:
                    new_columns = merged_index.columns[: self.max_index_width]
                    merged_index = Index(new_columns)
                if merged_index not in indexes:
                    self.cost_evaluation.estimate_size(merged_index)
                    indexes.add(merged_index)

    # based on AutoAdminAlgorithm
    def enumerate_greedy(
        self,
        workload,
        current_indexes,
        current_costs,
        candidate_indexes,
        number_indexes,
    ):
        assert (
            current_indexes & candidate_indexes == set()
        ), "Intersection of current and candidate indexes must be empty"
        if len(current_indexes) >= number_indexes:
            return current_indexes, current_costs

        # (index, cost)
        best_index = (None, None)

        logging.debug(f"Searching in {len(candidate_indexes)} indexes")

        for index in candidate_indexes:
            if (
                sum(idx.estimated_size for idx in current_indexes | {index})
                > self.disk_constraint
            ):
                # index configuration is too large
                continue
            cost = self._simulate_and_evaluate_cost(workload, current_indexes | {index})

            if not best_index[0] or cost < best_index[1]:
                best_index = (index, cost)
        if best_index[0] and best_index[1] < current_costs:
            current_indexes.add(best_index[0])
            candidate_indexes.remove(best_index[0])
            current_costs = best_index[1]

            logging.debug(f"Additional best index found: {best_index}")

            return self.enumerate_greedy(
                workload,
                current_indexes,
                current_costs,
                candidate_indexes,
                number_indexes,
            )
        return current_indexes, current_costs

    # copied from AutoAdminAlgorithm
    def _simulate_and_evaluate_cost(self, workload, indexes):
        cost = self.cost_evaluation.calculate_cost(workload, indexes, store_size=True)
        return round(cost, 2)
