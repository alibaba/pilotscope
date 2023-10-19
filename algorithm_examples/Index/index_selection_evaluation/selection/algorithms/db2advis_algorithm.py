import logging
import random
import time

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.selection_algorithm import DEFAULT_PARAMETER_VALUES, SelectionAlgorithm
from selection.utils import get_utilized_indexes, mb_to_b

# budget_MB: The algorithm can utilize the specified storage budget in MB.
# max_index_width: The number of columns an index can contain at maximum.
# try_variations_seconds: Time spent in TryVariations phase. See the original paper
#                         for further details
# try_variations_max_removals: Maximum number of index candidates that are remover per
#                              TryVariations step.
# The algorithm stops if the budget & the time for the TryVariations phase are exceeded.
DEFAULT_PARAMETERS = {
    "budget_MB": DEFAULT_PARAMETER_VALUES["budget_MB"],
    "max_index_width": DEFAULT_PARAMETER_VALUES["max_index_width"],
    "try_variations_seconds": 10,
    "try_variations_max_removals": 4,
}


# This algorithm resembles the index selection algorithm published in 2000 by Valentin
# et al. Details can be found in the original paper:
# Gary Valentin, Michael Zuliani, Daniel C. Zilio, Guy M. Lohman, Alan Skelley:
# DB2 Advisor: An Optimizer Smart Enough to Recommend Its Own Indexes. ICDE 2000: 101-110
#
# Please note, that this implementation does not reflect the behavior and performance
# of the original algorithm, which might be continuously enhanced and optimized.
class DB2AdvisAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(
            self, database_connector, parameters, DEFAULT_PARAMETERS
        )
        self.disk_constraint = mb_to_b(self.parameters["budget_MB"])
        self.try_variations_seconds = self.parameters["try_variations_seconds"]
        self.try_variations_max_removals = self.parameters["try_variations_max_removals"]

    def _calculate_best_indexes(self, workload):
        logging.info("Calculating best indexes DB2Advis")

        # The chosen generator is similar to the original "BFI" and
        # uses all syntactically relevant indexes.
        candidates = candidates_per_query(
            workload,
            self.parameters["max_index_width"],
            candidate_generator=syntactically_relevant_indexes,
        )
        utilized_indexes, query_details = get_utilized_indexes(
            workload, candidates, self.cost_evaluation, True
        )

        index_benefits = self._calculate_index_benefits(utilized_indexes, query_details)
        index_benefits_subsumed = self._combine_subsumed(index_benefits)
        selected_index_benefits = []
        disk_usage = 0
        for index_benefit in index_benefits_subsumed:
            if disk_usage + index_benefit.size() <= self.disk_constraint:
                selected_index_benefits.append(index_benefit)
                disk_usage += index_benefit.size()

        if self.try_variations_seconds > 0:
            selected_index_benefits = self._try_variations(
                selected_index_benefits, index_benefits_subsumed, workload
            )
        return [index_benefit.index for index_benefit in selected_index_benefits]

    def _calculate_index_benefits(self, candidates, query_results):
        indexes_benefit = []

        for index_candidate in candidates:
            benefit = 0

            for query, value in query_results.items():
                if index_candidate not in value["utilized_indexes"]:
                    continue
                # TODO adjust when having weights for queries
                benefit += value["cost_without_indexes"] - value["cost_with_indexes"]

            indexes_benefit.append(IndexBenefit(index_candidate, benefit))

        return sorted(indexes_benefit, reverse=True)

    # From the paper: "Combine any index subsumed
    # by an index with a higher ratio with that index."
    # The input must be a sorted list of IndexBenefit objects.
    # E.g., the output of _calculate_index_benefits()
    def _combine_subsumed(self, index_benefits):
        # There is no point in subsuming with less than two elements
        if len(index_benefits) < 2:
            return index_benefits

        assert index_benefits == sorted(
            index_benefits,
            reverse=True,
            key=lambda index_benefit: index_benefit.benefit_size_ratio(),
        ), "the input of _combine_subsumed must be sorted"

        index_benefits_to_remove = set()
        for high_ratio_pos, index_benefit_high_ratio in enumerate(index_benefits):
            if index_benefit_high_ratio in index_benefits_to_remove:
                continue
            # Test all following elements (with lower ratios) in the list
            iteration_pos = high_ratio_pos + 1
            for index_benefit_lower_ratio in index_benefits[iteration_pos:]:
                if index_benefit_lower_ratio in index_benefits_to_remove:
                    continue
                if index_benefit_high_ratio.index.subsumes(
                    index_benefit_lower_ratio.index
                ):
                    index_benefit_high_ratio.benefit += index_benefit_lower_ratio.benefit
                    index_benefits_to_remove.add(index_benefit_lower_ratio)

        result_set = set(index_benefits) - index_benefits_to_remove
        # Sorting of a set results in a list
        return sorted(result_set, reverse=True)

    def _try_variations(self, selected_index_benefits, index_benefits, workload):
        logging.debug(f"Try variation for {self.try_variations_seconds} seconds")
        start_time = time.time()

        not_used_index_benefits = set(index_benefits) - set(selected_index_benefits)

        min_length = min(len(selected_index_benefits), len(not_used_index_benefits))
        if self.try_variations_max_removals > min_length:
            self.try_variations_max_removals = min_length

        if self.try_variations_max_removals == 0:
            return selected_index_benefits

        current_cost = self._evaluate_workload(selected_index_benefits, workload)
        logging.debug(f"Initial cost \t{current_cost}")
        selected_index_benefits_set = set(selected_index_benefits)

        while start_time + self.try_variations_seconds > time.time():
            number_of_exchanges = (
                random.randrange(1, self.try_variations_max_removals)
                if self.try_variations_max_removals > 1
                else 1
            )
            indexes_to_remove = frozenset(
                random.sample(selected_index_benefits_set, k=number_of_exchanges)
            )

            new_variaton = set(selected_index_benefits_set - indexes_to_remove)
            new_variation_size = sum(
                [index_benefit.size() for index_benefit in new_variaton]
            )

            indexes_to_add = random.sample(not_used_index_benefits, k=number_of_exchanges)
            assert len(indexes_to_add) == len(
                indexes_to_remove
            ), "_try_variations must remove the same number of indexes that are added."
            for index_benefit in indexes_to_add:
                if index_benefit.size() + new_variation_size > self.disk_constraint:
                    continue
                new_variaton.add(index_benefit)
                new_variation_size += index_benefit.size()

            cost_of_variation = self._evaluate_workload(new_variaton, workload)

            if cost_of_variation < current_cost:
                logging.debug(f"Lower cost found \t{current_cost}")
                current_cost = cost_of_variation
                selected_index_benefits_set = new_variaton

        return selected_index_benefits_set

    def _evaluate_workload(self, index_benefits, workload):
        index_candidates = [index_benefit.index for index_benefit in index_benefits]
        return self.cost_evaluation.calculate_cost(workload, index_candidates)


class IndexBenefit:
    def __init__(self, index, benefit):
        self.index = index
        self.benefit = benefit

    def __eq__(self, other):
        if not isinstance(other, IndexBenefit):
            return False

        return other.index == self.index and self.benefit == other.benefit

    def __lt__(self, other):
        self_ratio = self.benefit_size_ratio()
        other_ratio = other.benefit_size_ratio()

        # For reproducible results, we also compare the index objects if the ratios
        # are equal
        if self_ratio == other_ratio:
            return self.index < other.index

        return self_ratio < other_ratio

    def __hash__(self):
        return hash((self.index, self.benefit))

    def __repr__(self):
        return f"IndexBenefit({self.index}, {self.benefit})"

    def size(self):
        return self.index.estimated_size

    def benefit_size_ratio(self):
        return self.benefit / self.size()
