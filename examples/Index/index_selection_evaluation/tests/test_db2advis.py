import time
import unittest
from unittest.mock import MagicMock

from selection.algorithms.db2advis_algorithm import DB2AdvisAlgorithm, IndexBenefit
from selection.dbms.postgres_dbms import PostgresDatabaseConnector
from selection.index import Index
from selection.query_generator import QueryGenerator
from selection.table_generator import TableGenerator
from selection.workload import Column, Query, Table, Workload


class MockConnector:
    def __init__(self):
        pass

    def drop_indexes(self):
        pass

    def simulate_index(self, index):
        pass


MB_TO_BYTES = 1000000


class TestDB2AdvisAlgorithmIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "tpch_test_db_database"
        cls.scale_factor = 0.001
        generating_connector = PostgresDatabaseConnector(None, autocommit=True)

        table_generator = TableGenerator(
            "tpch",
            cls.scale_factor,
            generating_connector,
            explicit_database_name=cls.db_name,
        )

        cls.db = PostgresDatabaseConnector(cls.db_name)
        query_generator = QueryGenerator(
            "tpch", cls.scale_factor, cls.db, [5, 6], table_generator.columns
        )
        cls.workload = Workload(query_generator.queries)

        generating_connector.close()

    @classmethod
    def tearDownClass(cls):
        cls.db.close()
        connector = PostgresDatabaseConnector(None, autocommit=True)
        if connector.database_exists(cls.db_name):
            connector.drop_database(cls.db_name)


class TestDB2AdvisAlgorithm(unittest.TestCase):
    def setUp(self):
        self.connector = MockConnector()
        self.algo = DB2AdvisAlgorithm(database_connector=self.connector)

        self.column_0 = Column("Col0")
        self.column_1 = Column("Col1")
        self.column_2 = Column("Col2")
        self.column_3 = Column("Col3")
        self.column_4 = Column("Col4")
        self.column_5 = Column("Col5")
        self.column_6 = Column("Col6")
        self.column_7 = Column("Col7")
        self.all_columns = [
            self.column_0,
            self.column_1,
            self.column_2,
            self.column_3,
            self.column_4,
            self.column_5,
            self.column_6,
            self.column_7,
        ]

        self.table = Table("Table0")
        self.table.add_columns(self.all_columns)

        self.query_0 = Query(
            0,
            "SELECT * FROM Table0 WHERE Col0 = 1 AND Col1 = 2 AND Col2 = 3;",
            self.all_columns,
        )
        # query_1 = Query(1, 'SELECT * FROM TableA WHERE ColA = 4;', [self.column_0])

    def test_db2advis_algorithm(self):
        # Should use default parameters if none are specified
        budget_in_mb = 500
        self.assertEqual(self.algo.disk_constraint, budget_in_mb * MB_TO_BYTES)
        self.assertEqual(self.algo.cost_evaluation.cost_estimation, "whatif")
        self.assertEqual(self.algo.try_variations_seconds, 10)
        self.assertEqual(self.algo.try_variations_max_removals, 4)

    def test_index_benefit__lt__(self):
        index_0 = Index([self.column_0])
        index_0.estimated_size = 1
        index_1 = Index([self.column_1])
        index_1.estimated_size = 2

        # Due to its size, index_0 has the better ratio
        index_benefit_0 = IndexBenefit(index_0, 10)
        index_benefit_1 = IndexBenefit(index_1, 10)
        self.assertTrue(index_benefit_1 < index_benefit_0)

        # The ratios are equal, the columns are taken into consideration
        index_benefit_1 = IndexBenefit(index_1, 20)
        self.assertTrue(index_benefit_0 < index_benefit_1)

    def test_calculate_index_benefits(self):
        index_0 = Index([self.column_0])
        index_0.estimated_size = 5
        index_1 = Index([self.column_1])
        index_1.estimated_size = 1
        index_2 = Index([self.column_2])
        index_2.estimated_size = 3

        query_result_0 = {
            "cost_without_indexes": 100,
            "cost_with_indexes": 50,
            "utilized_indexes": [index_0, index_1],
        }
        # Yes, negative benefit is possible
        query_result_1 = {
            "cost_without_indexes": 50,
            "cost_with_indexes": 60,
            "utilized_indexes": [index_1],
        }
        query_result_2 = {
            "cost_without_indexes": 60,
            "cost_with_indexes": 57,
            "utilized_indexes": [index_2],
        }
        query_result_3 = {
            "cost_without_indexes": 60,
            "cost_with_indexes": 60,
            "utilized_indexes": [],
        }
        query_results = {
            "q0": query_result_0,
            "q1": query_result_1,
            "q2": query_result_2,
            "q3": query_result_3,
        }

        index_benefits = self.algo._calculate_index_benefits(
            [index_0, index_1, index_2], query_results
        )
        expected_index_benefits = [
            IndexBenefit(index_1, 40),
            IndexBenefit(index_0, 50),
            IndexBenefit(index_2, 3),
        ]

        self.assertEqual(index_benefits, expected_index_benefits)

    def test_combine_subsumed(self):
        index_0_1 = Index([self.column_0, self.column_1])
        index_0_1.estimated_size = 2
        index_0 = Index([self.column_0])
        index_0.estimated_size = 1
        index_1 = Index([self.column_1])
        index_1.estimated_size = 1

        # Scenario 1. Index subsumed because better ratio for larger index
        index_benefits = [IndexBenefit(index_0_1, 21), IndexBenefit(index_0, 10)]
        subsumed = self.algo._combine_subsumed(index_benefits)
        expected = [IndexBenefit(index_0_1, 31)]
        self.assertEqual(subsumed, expected)

        # Scenario 2. Index not subsumed because better index has fewer attributes
        index_benefits = [IndexBenefit(index_0, 11), IndexBenefit(index_0_1, 20)]
        subsumed = self.algo._combine_subsumed(index_benefits)
        expected = [IndexBenefit(index_0, 11), IndexBenefit(index_0_1, 20)]
        self.assertEqual(subsumed, expected)

        # Scenario 3. Index not subsumed because last element does not match
        # attribute even though better ratio
        index_0_1_2 = Index([self.column_0, self.column_1, self.column_2])
        index_0_1_2.estimated_size = 3
        index_0_2 = Index([self.column_0, self.column_2])
        index_0_2.estimated_size = 2

        index_benefits = [IndexBenefit(index_0_1_2, 31), IndexBenefit(index_0_2, 20)]
        subsumed = self.algo._combine_subsumed(index_benefits)
        expected = [IndexBenefit(index_0_1_2, 31), IndexBenefit(index_0_2, 20)]
        self.assertEqual(subsumed, expected)

        # Scenario 4. Multi Index subsumed
        index_benefits = [IndexBenefit(index_0_1_2, 31), IndexBenefit(index_0_1, 20)]
        subsumed = self.algo._combine_subsumed(index_benefits)
        expected = [IndexBenefit(index_0_1_2, 51)]
        self.assertEqual(subsumed, expected)

        # Scenario 5. Multiple Indexes subsumed
        index_benefits = [
            IndexBenefit(index_0_1_2, 31),
            IndexBenefit(index_0_1, 20),
            IndexBenefit(index_0, 10),
        ]
        subsumed = self.algo._combine_subsumed(index_benefits)
        expected = [IndexBenefit(index_0_1_2, 61)]
        self.assertEqual(subsumed, expected)

        # Scenario 6. Input returned if len(input) < 2
        subsumed = self.algo._combine_subsumed([IndexBenefit(index_0_1, 21)])
        expected = [IndexBenefit(index_0_1, 21)]
        self.assertEqual(subsumed, expected)

        # Scenario 7. Input not sorted by ratio throws
        with self.assertRaises(AssertionError):
            subsumed = self.algo._combine_subsumed(
                [IndexBenefit(index_0, 10), IndexBenefit(index_0_1, 21)]
            )

    def test_evaluate_workload(self):
        index_0 = Index([self.column_0])
        index_1 = Index([self.column_1])
        self.algo.cost_evaluation.calculate_cost = MagicMock()

        self.algo._evaluate_workload(
            [IndexBenefit(index_0, 10), IndexBenefit(index_1, 9)], workload=[]
        )
        self.algo.cost_evaluation.calculate_cost.assert_called_once_with(
            [], [index_0, index_1]
        )

    def test_try_variations_time_limit(self):
        index_0 = Index([self.column_0])
        index_0.estimated_size = 1
        index_1 = Index([self.column_1])
        index_1.estimated_size = 1
        index_2 = Index([self.column_2])
        index_2.estimated_size = 1
        index_3 = Index([self.column_3])
        index_3.estimated_size = 1
        index_4 = Index([self.column_4])
        index_4.estimated_size = 1
        index_5 = Index([self.column_5])
        index_5.estimated_size = 1
        index_6 = Index([self.column_6])
        index_6.estimated_size = 1
        index_7 = Index([self.column_7])
        index_7.estimated_size = 5
        self.algo.cost_evaluation.calculate_cost = MagicMock(return_value=17)
        self.algo.try_variations_seconds = 0.2

        time_before = time.time()
        self.algo._try_variations(
            selected_index_benefits=frozenset([IndexBenefit(index_0, 1)]),
            index_benefits=frozenset([IndexBenefit(index_1, 1)]),
            workload=[],
        )
        self.assertGreaterEqual(
            time.time(), time_before + self.algo.try_variations_seconds
        )

        def fake(selected, workload):
            cost = 10
            if IndexBenefit(index_3, 1.5) in selected:
                cost -= 0.5
            if IndexBenefit(index_4, 0.5) in selected:
                cost += 0.5
            if IndexBenefit(index_1, 0.5) in selected:
                cost += 0.5
            if IndexBenefit(index_1, 0.5) in selected:
                cost += 0.5
            return cost

        # In this scenario a good index has not been selected (index_3).
        # We test three things:
        # (i)   That index_3 gets chosen by variation.
        # (ii)  That the weakest index from the original selection gets
        #         removed (index_1).
        # (iii) That index_4 does not get chosen even though it is better than index_1.
        self.algo._evaluate_workload = fake
        self.algo.try_variations_max_removals = 1
        self.algo.disk_constraint = 3
        new = self.algo._try_variations(
            selected_index_benefits=frozenset(
                [
                    IndexBenefit(index_0, 1),
                    IndexBenefit(index_1, 0.5),
                    IndexBenefit(index_2, 1),
                ]
            ),
            index_benefits=frozenset(
                [
                    IndexBenefit(index_0, 1),
                    IndexBenefit(index_1, 0.5),
                    IndexBenefit(index_2, 1),
                    IndexBenefit(index_3, 1.5),
                    IndexBenefit(index_4, 0.6),
                ]
            ),
            workload=[],
        )
        self.assertIn(IndexBenefit(index_3, 1.5), new)
        self.assertNotIn(IndexBenefit(index_4, 0.5), new)
        self.assertNotIn(IndexBenefit(index_1, 0.5), new)

        # Test that good index is not chosen because of storage restrictions
        new = self.algo._try_variations(
            selected_index_benefits=frozenset([IndexBenefit(index_0, 1)]),
            index_benefits=frozenset(
                [IndexBenefit(index_0, 1), IndexBenefit(index_7, 5)]
            ),
            workload=[],
        )
        self.assertEqual(new, set([IndexBenefit(index_0, 1)]))
