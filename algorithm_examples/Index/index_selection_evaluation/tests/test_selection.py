import sys
import unittest

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.dbms.postgres_dbms import PostgresDatabaseConnector
from selection.index_selection_evaluation import IndexSelection
from selection.query_generator import QueryGenerator
from selection.table_generator import TableGenerator
from selection.workload import Workload


class TestIndexSelection(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "tpch_test_db_index_selection"
        cls.index_selection = IndexSelection()
        db = PostgresDatabaseConnector(None, autocommit=True)

        SCALE_FACTOR = 0.001
        table_generator = TableGenerator(
            "tpch", SCALE_FACTOR, db, explicit_database_name=cls.db_name
        )
        db.close()

        cls.index_selection.setup_db_connector(cls.db_name, "postgres")

        # Filter worklaod
        query_generator = QueryGenerator(
            "tpch",
            SCALE_FACTOR,
            cls.index_selection.db_connector,
            [3, 14],
            table_generator.columns,
        )
        cls.small_tpch = Workload(query_generator.queries)

        query_generator = QueryGenerator(
            "tpch",
            SCALE_FACTOR,
            cls.index_selection.db_connector,
            [5, 6],
            table_generator.columns,
        )
        cls.tpch_5_and_6 = Workload(query_generator.queries)

    @classmethod
    def tearDownClass(cls):
        cls.index_selection.db_connector.close()

        connector = PostgresDatabaseConnector(None, autocommit=True)

        if connector.database_exists(cls.db_name):
            connector.drop_database(cls.db_name)

    def test_constructor(self):
        ind_sel = IndexSelection()
        ind_sel

    def test_auto_admin_algorithm(self):
        parameters = {"max_indexes": 3, "max_indexes_naive": 1}
        algorithm = self.index_selection.create_algorithm_object("auto_admin", parameters)
        algorithm.calculate_best_indexes(self.small_tpch)

    def test_all_indexes_algorithm(self):
        algo = self.index_selection.create_algorithm_object("all_indexes", None)
        algo.calculate_best_indexes(self.small_tpch)

    def test_drop_algorithm(self):
        parameters = {"max_indexes": 4}
        algo = self.index_selection.create_algorithm_object("drop", parameters)
        indexes = algo.calculate_best_indexes(self.small_tpch)
        self.assertEqual(len(indexes), 4)

    def test_dexter_algorithm(self):
        parameters = {}
        algo = self.index_selection.create_algorithm_object("dexter", parameters)
        indexes = algo.calculate_best_indexes(self.small_tpch)
        self.assertTrue(len(indexes) >= 1)

    def test_db2advis_algorithm(self):
        parameters = {}
        db2advis_algorithm = self.index_selection.create_algorithm_object(
            "db2advis", parameters
        )
        workload = Workload([self.small_tpch.queries[0]])

        possible = candidates_per_query(
            workload,
            max_index_width=3,
            candidate_generator=syntactically_relevant_indexes,
        )[0]
        indexes = db2advis_algorithm.calculate_best_indexes(workload)
        self.assertTrue(len(possible) >= len(indexes))

    def test_db2advis_algorithm_integration(self):
        parameters = {
            "budget_MB": 0.01,
            "try_variations_seconds": 0,
            "max_index_width": 1,
        }
        db2advis_algorithm = self.index_selection.create_algorithm_object(
            "db2advis", parameters
        )
        indexes = db2advis_algorithm.calculate_best_indexes(self.tpch_5_and_6)
        self.assertEqual(len(indexes), 1)
        self.assertEqual(str(indexes[0]), "I(C supplier.s_nationkey)")

        parameters = {
            "budget_MB": 0.04,
            "try_variations_seconds": 0,
            "max_index_width": 1,
        }
        db2advis_algorithm = self.index_selection.create_algorithm_object(
            "db2advis", parameters
        )
        indexes = db2advis_algorithm.calculate_best_indexes(self.tpch_5_and_6)
        self.assertEqual(len(indexes), 4)
        self.assertEqual(str(indexes[0]), "I(C supplier.s_nationkey)")
        self.assertEqual(str(indexes[1]), "I(C region.r_name)")
        self.assertEqual(str(indexes[2]), "I(C orders.o_custkey)")
        self.assertEqual(str(indexes[3]), "I(C nation.n_regionkey)")

    def test_anytime_algorithm_integration(self):
        parameters = {
            "budget_MB": 0.01,
            "max_index_width": 1,
        }
        anytime_algorithm = self.index_selection.create_algorithm_object(
            "anytime", parameters
        )
        indexes = anytime_algorithm.calculate_best_indexes(self.tpch_5_and_6)
        self.assertEqual(len(indexes), 1)
        self.assertEqual(str(indexes[0]), "I(C orders.o_custkey)")

        parameters = {
            "budget_MB": 0.1,
            "max_index_width": 1,
        }
        anytime_algorithm = self.index_selection.create_algorithm_object(
            "anytime", parameters
        )
        indexes = anytime_algorithm.calculate_best_indexes(self.tpch_5_and_6)
        self.assertEqual(len(indexes), 4)
        self.assertIn("I(C lineitem.l_suppkey)", str(indexes))
        self.assertIn("I(C orders.o_custkey)", str(indexes))
        self.assertIn("I(C supplier.s_nationkey)", str(indexes))
        # We only test for three exact occurences because the fourth selected index
        # is subject to random fluctuations based on database internals

    def test_run_cli_config(self):
        sys.argv = [sys.argv[0]]
        sys.argv.append("tests/config_tests.json")
        sys.argv.append("ERROR_LOG")
        sys.argv.append("DISABLE_OUTPUT_FILES")
        self.index_selection.run()

    def test_run_cli_config_timeout(self):
        sys.argv = [sys.argv[0]]
        sys.argv.append("tests/config_test_timeout.json")
        sys.argv.append("CRITICAL_LOG")
        sys.argv.append("DISABLE_OUTPUT_FILES")
        self.index_selection.run()


if __name__ == "__main__":
    unittest.main()
