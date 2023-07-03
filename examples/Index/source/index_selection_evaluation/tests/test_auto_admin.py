import unittest

from selection.algorithms.auto_admin_algorithm import AutoAdminAlgorithm
from selection.index import Index
from selection.workload import Workload
from tests.mock_connector import (
    MockConnector,
    column_A_0,
    column_A_1,
    column_A_2,
    mock_cache,
    query_0,
    query_1,
)


class TestAutoAdminAlgorithm(unittest.TestCase):
    def setUp(self):
        self.connector = MockConnector()
        self.database_name = "test_DB"

    def test_calculate_indexes_2indexes_3columns(self):
        algorithm = AutoAdminAlgorithm(
            database_connector=self.connector,
            parameters={"max_indexes": 2, "max_index_width": 3},
        )
        algorithm.cost_evaluation.cache = mock_cache
        algorithm.cost_evaluation._prepare_cost_calculation = (
            lambda indexes, store_size=False: None
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        self.assertEqual(
            set(index_selection), set([Index([column_A_0, column_A_1, column_A_2])])
        )

    def test_calculate_indexes_2indexes_2columns(self):
        algorithm = AutoAdminAlgorithm(
            database_connector=self.connector,
            parameters={"max_indexes": 2, "max_index_width": 2},
        )
        algorithm.cost_evaluation.cache = mock_cache
        algorithm.cost_evaluation._prepare_cost_calculation = (
            lambda indexes, store_size=False: None
        )

        index_selection = algorithm.calculate_best_indexes(Workload([query_0, query_1]))
        self.assertEqual(set(index_selection), set([Index([column_A_0, column_A_1])]))


if __name__ == "__main__":
    unittest.main()
