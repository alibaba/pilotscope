import unittest
from unittest.mock import MagicMock

import utils

from selection.algorithms.drop_heuristic_algorithm import DropHeuristicAlgorithm
from selection.index import Index
from selection.workload import Column, Query, Table, Workload


class MockConnector:
    def __init__(self):
        pass

    def drop_indexes(self):
        pass


class TestDropHeuristicAlgorithm(unittest.TestCase):
    def setUp(self):
        self.connector = MockConnector()
        self.algo = DropHeuristicAlgorithm(database_connector=self.connector)

        self.column_0 = Column("Col0")
        self.column_1 = Column("Col1")
        self.column_2 = Column("Col2")
        self.all_columns = [self.column_0, self.column_1, self.column_2]

        self.table = Table("TableA")
        self.table.add_columns(self.all_columns)

        self.index_0 = Index([self.column_0])
        self.index_1 = Index([self.column_1])
        self.index_2 = Index([self.column_2])

        query_0 = Query(0, "SELECT * FROM TableA WHERE Col0 = 4;", [self.column_0])
        query_1 = Query(
            1,
            "SELECT * FROM TableA WHERE Col0 = 1 AND Col1 = 2 AND Col2 = 3;",
            self.all_columns,
        )
        self.database_name = "test_DB"

        self.workload = Workload([query_0, query_1])
        self.algo.workload = self.workload
        self.algo.cost_evaluation.calculate_cost = MagicMock(
            side_effect=self._calculate_cost_mock
        )

    def test_drop_heuristic_algoritm(self):
        # Should use default parameters if none are specified
        self.assertEqual(self.algo.parameters["max_indexes"], 15)
        self.assertEqual(self.algo.cost_evaluation.cost_estimation, "whatif")

    def _calculate_cost_mock(self, workload, remaining_indexes):
        assert isinstance(
            remaining_indexes, set
        ), "The cost mock for the drop heuristic should only be called with index sets"

        index_combination_str = utils.index_combination_to_str(remaining_indexes)

        # In the first round, the lowest cost is achieved, if col1 is dropped.
        # In the second round, if col0 is dropped.
        index_combination_cost = {
            "tablea_col0_idx||tablea_col1_idx": 80,
            "tablea_col0_idx||tablea_col2_idx": 60,
            "tablea_col1_idx||tablea_col2_idx": 70,
            "tablea_col0_idx": 110,
            "tablea_col2_idx": 100,
        }

        return index_combination_cost[index_combination_str]

    def test_calculate_best_indexes_all_fit(self):
        self.algo.parameters["max_indexes"] = 3
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = frozenset([self.index_0, self.index_1, self.index_2])
        self.assertEqual(indexes, expected_indexes)

    def test_calculate_best_indexes_two_fit(self):
        self.algo.parameters["max_indexes"] = 2
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = frozenset([self.index_0, self.index_2])
        self.assertEqual(indexes, expected_indexes)
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_0, self.index_1])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_0, self.index_2])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_1, self.index_2])
        )
        self.assertEqual(self.algo.cost_evaluation.calculate_cost.call_count, 3)

    def test_calculate_best_indexes_one_fits(self):
        self.algo.parameters["max_indexes"] = 1
        indexes = self.algo._calculate_best_indexes(self.workload)
        expected_indexes = frozenset([self.index_2])
        self.assertEqual(indexes, expected_indexes)
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_0, self.index_1])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_0, self.index_2])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_1, self.index_2])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_0])
        )
        self.algo.cost_evaluation.calculate_cost.assert_any_call(
            self.workload, set([self.index_2])
        )
        self.assertEqual(self.algo.cost_evaluation.calculate_cost.call_count, 5)

    def test_calculate_best_indexes_none_fits(self):
        self.algo.parameters["max_indexes"] = 0
        with self.assertRaises(AssertionError):
            self.algo._calculate_best_indexes(self.workload)
