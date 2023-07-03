import itertools
import logging

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.index import Index, index_merge, index_split
from selection.selection_algorithm import DEFAULT_PARAMETER_VALUES, SelectionAlgorithm
from selection.utils import get_utilized_indexes, indexes_by_table, mb_to_b

# allowed_transformations: The algorithm transforms index configurations. Via this
#                          parameter, the allowed transformations can be chosen.
#                          In the original paper, 5 transformations are documented.
#                          Except for "Promotion to clustered" all transformations are
#                          implemented and part of the algorithm's default configuration.
# budget_MB: The algorithm can utilize the specified storage budget in MB.
# max_index_width: The number of columns an index can contain at maximum.
DEFAULT_PARAMETERS = {
    "allowed_transformations": ["splitting", "merging", "prefixing", "removal"],
    "budget_MB": DEFAULT_PARAMETER_VALUES["budget_MB"],
    "max_index_width": DEFAULT_PARAMETER_VALUES["max_index_width"],
}


# This algorithm is a reimplementation of Bruno's and Chaudhuri's relaxation-based
# approach to physical database design.
# Details can be found in the original paper:
# Nicolas Bruno, Surajit Chaudhuri: Automatic Physical Database Tuning:
# A Relaxation-based Approach. SIGMOD Conference 2005: 227-238
class RelaxationAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(
            self, database_connector, parameters, DEFAULT_PARAMETERS
        )
        self.disk_constraint = mb_to_b(self.parameters["budget_MB"])
        self.transformations = self.parameters["allowed_transformations"]
        self.max_index_width = self.parameters["max_index_width"]
        assert set(self.transformations) <= {
            "splitting",
            "merging",
            "prefixing",
            "removal",
        }

    def _calculate_best_indexes(self, workload):
        logging.info("Calculating best indexes Relaxation")

        # Generate syntactically relevant candidates
        candidates = candidates_per_query(
            workload,
            self.parameters["max_index_width"],
            candidate_generator=syntactically_relevant_indexes,
        )

        # Obtain best (utilized) indexes per query
        candidates, _ = get_utilized_indexes(workload, candidates, self.cost_evaluation)

        # CP in Figure 5
        cp = candidates.copy()
        cp_size = sum(index.estimated_size for index in cp)
        cp_cost = self.cost_evaluation.calculate_cost(workload, cp, store_size=True)
        while cp_size > self.disk_constraint:
            logging.debug(
                f"Size of current configuration: {cp_size}. "
                f"Budget: {self.disk_constraint}."
            )

            # Pick a configuration that can be relaxed
            # TODO: Currently only one is considered

            # Relax the configuration
            best_relaxed = None
            best_relaxed_size = None
            lowest_relaxed_penalty = None

            cp_by_table = indexes_by_table(cp)

            for transformation in self.transformations:
                for (
                    relaxed,
                    relaxed_storage_savings,
                ) in self._configurations_by_transformation(
                    cp, cp_by_table, transformation
                ):
                    relaxed_cost = self.cost_evaluation.calculate_cost(
                        workload, relaxed, store_size=True
                    )
                    # Note, some transformations could also decrease the cost,
                    # indicated by a negative value
                    relaxed_cost_increase = relaxed_cost - cp_cost

                    if relaxed_storage_savings <= 0:
                        # Some transformations could increase or not affect the storage
                        # consumption. For termination of the algorithm, the storage
                        # savings must be positive
                        continue
                    relaxed_considered_storage_savings = min(
                        relaxed_storage_savings, cp_size - self.disk_constraint
                    )

                    if relaxed_cost_increase < 0:
                        # For a (fixed) cost decrease (indicated by a negative value
                        # for relaxed_cost_increase), higher storage savings produce
                        # a lower penalty
                        relaxed_penalty = relaxed_cost_increase * relaxed_storage_savings
                    else:
                        relaxed_penalty = (
                            relaxed_cost_increase / relaxed_considered_storage_savings
                        )
                    if best_relaxed is None or relaxed_penalty < lowest_relaxed_penalty:
                        # set new best relaxed configuration
                        best_relaxed = relaxed
                        best_relaxed_size = cp_size - relaxed_considered_storage_savings
                        lowest_relaxed_penalty = relaxed_penalty

            cp = best_relaxed
            cp_size = best_relaxed_size

        return list(cp)

    def _configurations_by_transformation(
        self, input_configuration, input_configuration_by_table, transformation
    ):
        if transformation == "prefixing":
            for index in input_configuration:
                for prefix in index.prefixes():
                    relaxed = input_configuration.copy()
                    relaxed.remove(index)
                    relaxed_storage_savings = index.estimated_size
                    if prefix not in relaxed:
                        relaxed.add(prefix)
                        self.cost_evaluation.estimate_size(prefix)
                        relaxed_storage_savings -= prefix.estimated_size
                    yield relaxed, relaxed_storage_savings
        elif transformation == "removal":
            for index in input_configuration:
                relaxed = input_configuration.copy()
                relaxed.remove(index)
                yield relaxed, index.estimated_size
        elif transformation == "merging":
            for table in input_configuration_by_table:
                for index1, index2 in itertools.permutations(
                    input_configuration_by_table[table], 2
                ):
                    relaxed = input_configuration.copy()
                    merged_index = index_merge(index1, index2)
                    if len(merged_index.columns) > self.max_index_width:
                        new_columns = merged_index.columns[: self.max_index_width]
                        merged_index = Index(new_columns)

                    relaxed -= {index1, index2}
                    relaxed_storage_savings = (
                        index1.estimated_size + index2.estimated_size
                    )
                    if merged_index not in relaxed:
                        relaxed.add(merged_index)
                        self.cost_evaluation.estimate_size(merged_index)
                        relaxed_storage_savings -= merged_index.estimated_size
                    yield relaxed, relaxed_storage_savings
        elif transformation == "splitting":
            for table in input_configuration_by_table:
                for index1, index2 in itertools.permutations(
                    input_configuration_by_table[table], 2
                ):
                    relaxed = input_configuration.copy()
                    indexes_by_splitting = index_split(index1, index2)
                    if indexes_by_splitting is None:
                        # no splitting for index permutation possible
                        continue
                    relaxed -= {index1, index2}
                    relaxed_storage_savings = (
                        index1.estimated_size + index2.estimated_size
                    )
                    for index in indexes_by_splitting - relaxed:
                        relaxed.add(index)
                        self.cost_evaluation.estimate_size(index)
                        relaxed_storage_savings -= index.estimated_size
                    yield relaxed, relaxed_storage_savings
