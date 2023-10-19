import unittest

from selection.dbms.postgres_dbms import PostgresDatabaseConnector
from selection.selection_algorithm import NoIndexAlgorithm, SelectionAlgorithm
from selection.table_generator import TableGenerator
from selection.workload import Workload


class TestAlgorithm(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "tpch_test_db_algorithm"

        cls.db_connector = PostgresDatabaseConnector(None, autocommit=True)
        TableGenerator(
            "tpch", 0.001, cls.db_connector, explicit_database_name=cls.db_name
        )
        cls.selection_algorithm = SelectionAlgorithm(cls.db_connector, {"test": 24})

        cls.db_connector.close()

    @classmethod
    def tearDownClass(cls):
        connector = PostgresDatabaseConnector(None, autocommit=True)
        if connector.database_exists(cls.db_name):
            connector.drop_database(cls.db_name)

    def test_parameters(self):
        params = self.selection_algorithm.parameters
        self.assertEqual(params, {"test": 24})

    def test_calculate_best(self):
        workload = Workload([])
        with self.assertRaises(NotImplementedError):
            self.selection_algorithm.calculate_best_indexes(workload)

    def test_calculate_best_only_executable_once(self):
        workload = Workload([])
        selection_algorithm = NoIndexAlgorithm(
            PostgresDatabaseConnector(None, autocommit=True)
        )
        self.assertFalse(selection_algorithm.did_run)

        selection_algorithm.calculate_best_indexes(workload)
        self.assertTrue(selection_algorithm.did_run)

        with self.assertRaises(AssertionError):
            selection_algorithm.calculate_best_indexes(workload)

    def test_cost_eval(self):
        db_conn = self.selection_algorithm.cost_evaluation.db_connector
        self.assertEqual(db_conn, self.db_connector)

    def test_cost_eval_cost_empty_workload(self):
        workload = Workload([])
        cost_eval = self.selection_algorithm.cost_evaluation
        cost = cost_eval.calculate_cost(workload, [])
        self.assertEqual(cost, 0)


if __name__ == "__main__":
    unittest.main()
