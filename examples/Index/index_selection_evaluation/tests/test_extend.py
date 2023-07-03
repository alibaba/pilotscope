import sys
import unittest
from unittest.mock import MagicMock

from selection.algorithms.extend_algorithm import ExtendAlgorithm
from selection.index import Index
from selection.selection_algorithm import DEFAULT_PARAMETER_VALUES
from selection.utils import mb_to_b
from selection.workload import Column, Query, Table, Workload


class MockConnector:
    def __init__(self):
        pass

    def drop_indexes(self):
        pass


class MockCostEvaluation:
    def __init__(self):
        pass


def index_combination_to_str(index_combination):
    indexes_as_str = sorted([x.index_idx() for x in index_combination])

    return "||".join(indexes_as_str)


class TestExtendAlgorithm(unittest.TestCase):
    def setUp(self):
        self.connector = MockConnector()
        self.algo = ExtendAlgorithm(database_connector=self.connector)

        self.column_1 = Column("ColA")
        self.column_2 = Column("ColB")
        self.column_3 = Column("ColC")
        self.all_columns = [self.column_1, self.column_2, self.column_3]

        self.table = Table("TableA")
        self.table.add_columns(self.all_columns)

        self.index_1 = Index([self.column_1])
        self.index_1.estimated_size = 5
        self.index_2 = Index([self.column_2])
        self.index_2.estimated_size = 1
        self.index_3 = Index([self.column_3])
        self.index_3.estimated_size = 3

        query_1 = Query(0, "SELECT * FROM TableA WHERE ColA = 4;", [self.column_1])
        query_2 = Query(
            1,
            "SELECT * FROM TableA WHERE ColA = 1 AND ColB = 2 AND ColC = 3;",
            self.all_columns,
        )
        self.database_name = "test_DB"

        self.workload = Workload([query_1, query_2])
        self.algo.workload = self.workload

    def test_attach_to_indexes(self):
        index_combination = [self.index_1, self.index_2]
        candidate = self.index_3
        self.algo.initial_cost = 10
        best = {"combination": [], "benefit_to_size_ratio": 0}
        self.algo._evaluate_combination = MagicMock()
        self.algo._attach_to_indexes(
            index_combination, candidate, best, self.algo.initial_cost
        )

        first_new_combination = [
            index_combination[1],
            Index(index_combination[0].columns + candidate.columns),
        ]
        self.algo._evaluate_combination.assert_any_call(
            first_new_combination, best, self.algo.initial_cost, 5
        )

        second_new_combination = [
            index_combination[0],
            Index(index_combination[1].columns + candidate.columns),
        ]
        self.algo._evaluate_combination.assert_any_call(
            second_new_combination, best, self.algo.initial_cost, 1
        )

        multi_column_candidate = Index([self.column_2, self.column_3])
        with self.assertRaises(AssertionError):
            self.algo._attach_to_indexes(
                index_combination, multi_column_candidate, best, self.algo.initial_cost
            )

    def test_remove_impossible_canidates(self):
        # All Fit
        candidates = [self.index_1, self.index_2, self.index_3]
        self.algo.budget = 10
        new_candidates = self.algo._get_candidates_within_budget(
            index_combination_size=0, candidates=candidates
        )
        expected_candidates = candidates
        self.assertEqual(new_candidates, expected_candidates)

        # None fit because of algorithm budget
        self.algo.budget = 0
        new_candidates = self.algo._get_candidates_within_budget(
            index_combination_size=0, candidates=candidates
        )
        expected_candidates = []
        self.assertEqual(new_candidates, expected_candidates)

        # None fit because of index_combination_size
        self.algo.budget = 10
        new_candidates = self.algo._get_candidates_within_budget(
            index_combination_size=10, candidates=candidates
        )
        expected_candidates = []
        self.assertEqual(new_candidates, expected_candidates)

        # Some do not fit
        self.algo.budget = 4
        new_candidates = self.algo._get_candidates_within_budget(
            index_combination_size=1, candidates=candidates
        )
        expected_candidates = [self.index_2, self.index_3]
        self.assertEqual(new_candidates, expected_candidates)

        # Index with size none is not removed even though there is no space left
        self.index_1.estimated_size = None
        self.algo.budget = 0
        new_candidates = self.algo._get_candidates_within_budget(
            index_combination_size=0, candidates=candidates
        )
        expected_candidates = [self.index_1]
        self.assertEqual(new_candidates, expected_candidates)

    def test_evaluate_combination_worse_ratio(self):
        # Mock the internal algorithm state
        best_old = {"combination": [self.index_2], "benefit_to_size_ratio": 10}
        best_input = best_old.copy()
        new_index_combination = [self.index_1]

        # Mock internally called cost function
        self.algo.cost_evaluation.calculate_cost = MagicMock(return_value=4)
        self.algo.initial_cost = 14

        cost = self.algo.cost_evaluation.calculate_cost(
            self.workload, new_index_combination, store_size=True
        )
        benefit = self.algo.initial_cost - cost
        size = sum(x.estimated_size for x in new_index_combination)
        ratio = benefit / size
        assert best_old["benefit_to_size_ratio"] >= ratio

        # Above's specification leads to a benefit of 10. The index cost is 5.
        # The ratio is 2 which is worse than above's 10. Hence, best_input
        # should not change
        self.algo._evaluate_combination(
            new_index_combination, best_input, self.algo.initial_cost
        )

        expected_best = best_old
        self.assertEqual(expected_best, best_input)

    def test_evaluate_combination_better_ratio_too_large(self):
        # Mock the internal algorithm state
        self.algo.budget = 2
        best_old = {
            "combination": [self.index_2],
            "benefit_to_size_ratio": 1,
            "cost": 4,
        }
        best_input = best_old.copy()
        new_index_combination = [self.index_1]

        # Mock internally called cost function
        self.algo.cost_evaluation.calculate_cost = MagicMock(return_value=4)
        self.algo.initial_cost = 14

        cost = self.algo.cost_evaluation.calculate_cost(
            self.workload, new_index_combination, store_size=True
        )
        benefit = self.algo.initial_cost - cost
        size = sum(x.estimated_size for x in new_index_combination)
        ratio = benefit / size
        assert best_old["benefit_to_size_ratio"] < ratio

        # Above's specification leads to a benefit of 10. The index cost is 5.
        # The ratio is 2 which is better than above's 1. But the remaining budget
        # is not sufficient.
        self.algo._evaluate_combination(
            new_index_combination, best_input, self.algo.initial_cost
        )

        expected_best = best_old
        self.assertEqual(expected_best, best_input)

    def test_evaluate_combination_better_ratio(self):
        # Mock the internal algorithm state
        best_old = {
            "combination": [self.index_2],
            "benefit_to_size_ratio": 1,
        }
        best_input = best_old.copy()
        new_index_combination = [self.index_1]

        # Mock internally called cost function
        self.algo.cost_evaluation.calculate_cost = MagicMock(return_value=4)
        self.algo.initial_cost = 14

        # Above's specification leads to a benefit of 10. The index cost is 5.
        # The ratio is 2 which is better than above's 1. Hence, best_input should change
        self.algo._evaluate_combination(
            new_index_combination, best_input, self.algo.initial_cost
        )

        expected_best = {
            "combination": new_index_combination,
            "benefit_to_size_ratio": 2,
            "cost": 4,
        }
        self.assertEqual(expected_best, best_input)

    def test_extend_algoritm(self):
        # Should use default parameters if none are specified
        self.assertEqual(self.algo.budget, mb_to_b(DEFAULT_PARAMETER_VALUES["budget_MB"]))
        self.assertEqual(self.algo.cost_evaluation.cost_estimation, "whatif")

    def _assign_size_1(self, index):
        index_sizes = {
            "tablea_cola_idx": 1,
            "tablea_colb_idx": 1,
            "tablea_colc_idx": 1,
            "tablea_colb_cola_idx": 2,
            "tablea_colb_colc_idx": 2,
            "tablea_colc_cola_idx": 2,
            "tablea_colc_colb_idx": 2,
        }

        # Assume large size if index not in mocked size table
        if index.index_idx() not in index_sizes:
            return sys.maxsize

        index.estimated_size = index_sizes[index.index_idx()]

    def _calculate_cost_mock_1(self, workload, indexes, store_size):
        for index in indexes:
            self._assign_size_1(index)

        index_combination_str = index_combination_to_str(indexes)

        index_combination_cost = {
            "": 100,
            "tablea_cola_idx": 90,
            "tablea_colb_idx": 80,
            "tablea_colc_idx": 70,
            "tablea_cola_idx||tablea_colc_idx": 60,
            "tablea_colb_idx||tablea_colc_idx": 50,
            "tablea_colc_idx||tablea_cola_idx": 60,
            "tablea_colc_idx||tablea_colb_idx": 50,
            "tablea_cola_idx||tablea_colb_idx||tablea_colc_idx": 40,
            # Below here multi, they do not result in benefit
            "tablea_colb_idx||tablea_colc_cola_idx": 1000,
            "tablea_colb_idx||tablea_colc_colb_idx": 1000,
            "tablea_colb_cola_idx||tablea_colc_idx": 1000,
            "tablea_colb_colc_idx||tablea_colc_idx": 1000,
            "tablea_colc_cola_idx": 1000,
            "tablea_colc_colb_idx": 1000,
            "tablea_colc_idx||tablea_colb_cola_idx": 1000,
            "tablea_colc_idx||tablea_colb_colc_idx": 1000,
            "tablea_colc_cola_idx||tablea_colb_idx": 1000,
            "tablea_colc_colb_idx||tablea_colb_idx": 1000,
        }

        # Assume high cost if index not in mocked cost table
        if index_combination_str not in index_combination_cost:
            return sys.maxsize

        return index_combination_cost[index_combination_str]

    # In this scenario, only single column indexes make sense.
    # They all have the same size but different benefits.
    def test_calculate_best_indexes_scenario_1(self):
        self.algo.cost_evaluation.calculate_cost = MagicMock(
            side_effect=self._calculate_cost_mock_1
        )

        # Each one alone of the single column indexes would fit,
        # but the one with the best benefit/cost ratio is chosen
        self.algo.budget = 1
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [Index([self.column_3])]
        self.assertEqual(indexes, expected_indexes)

        # Two single column indexes would fit, but the two best ones are chosen
        self.algo.budget = 2
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [Index([self.column_3]), Index([self.column_2])]
        self.assertEqual(indexes, expected_indexes)

        # All single column indexes are chosen
        self.algo.budget = 3
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [
            Index([self.column_3]),
            Index([self.column_2]),
            Index([self.column_1]),
        ]
        self.assertEqual(indexes, expected_indexes)

    def _assign_size_2(self, index):
        index_sizes = {
            "tablea_cola_idx": 1,
            "tablea_colb_idx": 3,
            "tablea_colc_idx": 5,
            "tablea_cola_colb_idx": 20,
            "tablea_cola_colc_idx": 20,
            "tablea_colb_cola_idx": 20,
            "tablea_colb_colc_idx": 20,
            "tablea_colc_cola_idx": 20,
            "tablea_colc_colb_idx": 20,
        }

        index.estimated_size = index_sizes[index.index_idx()]

    def _calculate_cost_mock_2(self, workload, indexes, store_size):
        for index in indexes:
            self._assign_size_2(index)

        index_combination_str = index_combination_to_str(indexes)

        index_combination_cost = {
            "": 100,
            "tablea_cola_idx": 90,
            "tablea_colb_idx": 80,
            "tablea_colc_idx": 70,
            "tablea_cola_idx||tablea_colb_idx": 70,
            "tablea_cola_idx||tablea_colc_idx": 60,
            "tablea_colb_idx||tablea_colc_idx": 50,
            "tablea_cola_idx||tablea_colb_idx||tablea_colc_idx": 40,
            # Below here multi, they do not result in benefit
            "tablea_cola_colb_idx": 1000,
            "tablea_cola_colc_idx": 1000,
            "tablea_colb_colc_idx": 1000,
            "tablea_cola_idx||tablea_colb_cola_idx": 1000,
            "tablea_cola_idx||tablea_colb_colc_idx": 1000,
            "tablea_cola_idx||tablea_colc_cola_idx": 1000,
            "tablea_cola_idx||tablea_colc_colb_idx": 1000,
            "tablea_cola_colb_idx||tablea_colb_idx": 1000,
            "tablea_cola_colb_idx||tablea_colc_idx": 1000,
            "tablea_cola_colc_idx||tablea_colb_idx": 1000,
        }

        # Assume high cost if index not in mocked cost table
        if index_combination_str not in index_combination_cost:
            return sys.maxsize

        return index_combination_cost[index_combination_str]

    # In this scenario, only single column indexes make sense.
    # Size and benefit are antiproportional.
    def test_calculate_best_indexes_scenario_2(self):
        self.algo.cost_evaluation.calculate_cost = MagicMock(
            side_effect=self._calculate_cost_mock_2
        )

        # There is only one index fitting the budget
        self.algo.budget = 1
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [Index([self.column_1])]
        self.assertEqual(indexes, expected_indexes)

        # Theoretically, two indexes fit, but one has a better benefit/cost ratio
        self.algo.budget = 3
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [Index([self.column_1])]
        self.assertEqual(indexes, expected_indexes)

        # The two indexes with the best ratio should be chosen
        self.algo.budget = 5
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [Index([self.column_1]), Index([self.column_2])]
        self.assertEqual(indexes, expected_indexes)

        # All single column indexes are chosen
        self.algo.budget = 9
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = [
            Index([self.column_1]),
            Index([self.column_2]),
            Index([self.column_3]),
        ]
        self.assertEqual(indexes, expected_indexes)

    def _assign_size_3(self, index):
        index_sizes = {
            "tablea_cola_idx": 2,
            "tablea_colb_idx": 1.9,
            "tablea_cola_colb_idx": 4,
            "tablea_colb_cola_idx": 3,
        }

        index.estimated_size = index_sizes[index.index_idx()]

    def _calculate_cost_mock_3(self, workload, indexes, store_size):
        for index in indexes:
            self._assign_size_3(index)

        index_combination_str = index_combination_to_str(indexes)

        index_combination_cost = {
            "": 100,
            "tablea_cola_idx": 80,
            "tablea_colb_idx": 80,
            "tablea_cola_idx||tablea_colb_idx": 70,
            # Below here multi, they do not result in benefit
            "tablea_cola_colb_idx": 60,
            "tablea_colb_cola_idx": 60,
            "tablea_colb_cola_idx||tablea_colb_idx": 60,
        }

        return index_combination_cost[index_combination_str]

    # In this scenario, multi column indexes dominate single column indexes.
    def test_calculate_best_indexes_scenario_3(self):
        query_1 = Query(
            0,
            "SELECT * FROM TableA WHERE ColA = 1 AND ColB = 2;",
            [self.column_1, self.column_2],
        )
        workload = Workload([query_1])
        self.algo.cost_evaluation.calculate_cost = MagicMock(
            side_effect=self._calculate_cost_mock_3
        )

        # Budget too small for multi
        self.algo.budget = 2
        indexes = self.algo._calculate_best_indexes(workload)
        expected_indexes = [Index([self.column_2])]
        self.assertEqual(indexes, expected_indexes)

        # Picks multi with best ratio
        self.algo.budget = 4
        indexes = self.algo._calculate_best_indexes(workload)
        expected_indexes = [Index([self.column_2, self.column_1])]
        self.assertEqual(indexes, expected_indexes)
