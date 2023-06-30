import unittest
from unittest.mock import patch

from selection.algorithms.relaxation_algorithm import RelaxationAlgorithm
from selection.index import Index
from selection.workload import Workload
from tests.mock_connector import (
    MockConnector,
    column_A_0,
    column_A_1,
    mock_cache,
    query_0,
    query_1,
)


class TestRelaxationAlgorithm(unittest.TestCase):
    def setUp(self):
        self.connector = MockConnector()

    @staticmethod
    def set_estimated_index_sizes(indexes, store_size=True):
        for index in indexes:
            if index.estimated_size is None:
                index.estimated_size = len(index.columns) * 1000 * 1000

    @staticmethod
    def set_estimated_index_size(index):
        index.estimated_size = len(index.columns) * 1000 * 1000

    @patch("selection.algorithms.relaxation_algorithm.get_utilized_indexes")
    def test_calculate_indexes_3000MB_2column(self, get_utilized_indexes_mock):
        algorithm = RelaxationAlgorithm(
            database_connector=self.connector,
            parameters={"max_index_width": 2, "budget_MB": 3},
        )
        algorithm.cost_evaluation.cache = mock_cache
        algorithm.cost_evaluation._prepare_cost_calculation = (
            self.set_estimated_index_sizes
        )
        algorithm.cost_evaluation.estimate_size = self.set_estimated_index_size
        get_utilized_indexes_mock.return_value = (
            {
                Index([column_A_0], 1000 * 1000),
                Index([column_A_0, column_A_1], 2000 * 1000),
            },
            None,
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        self.assertEqual(
            set(index_selection),
            set([Index([column_A_0]), Index([column_A_0, column_A_1])]),
        )

    @patch("selection.algorithms.relaxation_algorithm.get_utilized_indexes")
    def test_calculate_indexes_2MB_2column(self, get_utilized_indexes_mock):
        algorithm = RelaxationAlgorithm(
            database_connector=self.connector,
            parameters={"max_index_width": 2, "budget_MB": 2},
        )
        algorithm.cost_evaluation.cache = mock_cache
        algorithm.cost_evaluation._prepare_cost_calculation = (
            self.set_estimated_index_sizes
        )
        algorithm.cost_evaluation.estimate_size = self.set_estimated_index_size
        get_utilized_indexes_mock.return_value = (
            {
                Index([column_A_0], 1000 * 1000),
                Index([column_A_0, column_A_1], 2000 * 1000),
            },
            None,
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        self.assertEqual(set(index_selection), set([Index([column_A_0, column_A_1])]))

    @patch("selection.algorithms.relaxation_algorithm.get_utilized_indexes")
    def test_calculate_indexes_1MB_2column(self, get_utilized_indexes_mock):
        algorithm = RelaxationAlgorithm(
            database_connector=self.connector,
            parameters={"max_index_width": 2, "budget_MB": 1},
        )
        algorithm.cost_evaluation.cache = mock_cache

        algorithm.cost_evaluation._prepare_cost_calculation = (
            self.set_estimated_index_sizes
        )
        algorithm.cost_evaluation.estimate_size = self.set_estimated_index_size
        get_utilized_indexes_mock.return_value = (
            {
                Index([column_A_0], 1000 * 1000),
                Index([column_A_0, column_A_1], 2000 * 1000),
            },
            None,
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        # The single column index is dropped first, because of the lower penalty.
        # The multi column index is prefixed second.
        self.assertEqual(set(index_selection), {Index([column_A_0])})

    @patch("selection.algorithms.relaxation_algorithm.get_utilized_indexes")
    def test_calculate_indexes_500kB_2column(self, get_utilized_indexes_mock):
        algorithm = RelaxationAlgorithm(
            database_connector=self.connector,
            parameters={"max_index_width": 2, "budget_MB": 0.5},
        )
        algorithm.cost_evaluation.cache = mock_cache
        algorithm.cost_evaluation._prepare_cost_calculation = (
            self.set_estimated_index_sizes
        )
        algorithm.cost_evaluation.estimate_size = self.set_estimated_index_size
        get_utilized_indexes_mock.return_value = (
            {
                Index([column_A_0], 1000 * 1000),
                Index([column_A_0, column_A_1], 2000 * 1000),
            },
            None,
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        self.assertEqual(set(index_selection), set())


if __name__ == "__main__":
    unittest.main()
