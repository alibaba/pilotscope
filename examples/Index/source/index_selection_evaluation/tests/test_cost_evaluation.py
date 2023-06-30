import unittest
from unittest.mock import MagicMock

from selection.candidate_generation import syntactically_relevant_indexes
from selection.cost_evaluation import CostEvaluation
from selection.index import Index
from selection.workload import Column, Query, Table, Workload


class MockConnector:
    def __init__(self):
        pass


class MockWhatIf:
    def __init__(self):
        pass


class TestCostEvaluation(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "TestDB"

        cls.table = Table("TestTableA")
        cls.columns = [
            Column("Col0"),
            Column("Col1"),
            Column("Col2"),
            Column("Col3"),
            Column("Col4"),
        ]
        cls.table.add_columns(cls.columns)

        cls.queries = [
            Query(0, "SELECT * FROM TestTableA WHERE Col0 = 4", [cls.columns[0]]),
            Query(1, "SELECT * FROM TestTableA WHERE Col1 = 3", [cls.columns[1]]),
            Query(
                2,
                "SELECT * FROM TestTableA WHERE Col0 = 14 AND Col1 = 13",
                [cls.columns[0], cls.columns[1]],
            ),
        ]

        cls.workload = Workload(cls.queries)

    def setUp(self):
        # We mock the connector because it is needed by the cost evaluation.
        # By also mocking some of its methods, we can test how often these are called.
        self.connector = MockConnector()
        self.connector.get_cost = MagicMock(return_value=3)
        self.connector.simulate_index = MagicMock(
            return_value=[0, "index_name"]
        )  # index_oid, index_name

        self.cost_evaluation = CostEvaluation(self.connector)

    def tearDown(self):
        self.connector.simulate_index.reset_mock()
        self.connector.get_cost.reset_mock()

    def test_relevant_indexes(self):
        index_0 = Index([self.columns[0]])
        index_1 = Index([self.columns[1]])

        result = self.cost_evaluation._relevant_indexes(self.queries[0], indexes=set())
        self.assertEqual(result, frozenset())

        result = self.cost_evaluation._relevant_indexes(self.queries[0], set([index_0]))
        self.assertEqual(result, frozenset([index_0]))

        result = self.cost_evaluation._relevant_indexes(
            self.queries[0], set([index_1, index_0])
        )
        self.assertEqual(result, frozenset([index_0]))

        result = self.cost_evaluation._relevant_indexes(
            self.queries[2], set([index_1, index_0])
        )
        self.assertEqual(result, frozenset([index_1, index_0]))

    def test_cost_requests(self):
        self.assertEqual(self.cost_evaluation.cost_requests, 0)

        CALCULATE_COST_CALLS = 3
        for i in range(CALCULATE_COST_CALLS):
            self.cost_evaluation.calculate_cost(self.workload, indexes=set())

        expected_cost_requests = len(self.workload.queries) * CALCULATE_COST_CALLS
        self.assertEqual(self.cost_evaluation.cost_requests, expected_cost_requests)

        # Since we did not change the index configuration, all calls,
        # except the first round, should be cached
        expected_cache_hits = expected_cost_requests - len(self.workload.queries)
        self.assertEqual(self.cost_evaluation.cache_hits, expected_cache_hits)

        # Therefore, actual calls to the database connector's get_cost method should
        # be limited by the number of queries as it is not called for cached costs.
        self.assertEqual(self.connector.get_cost.call_count, len(self.workload.queries))

    def test_cache_hit(self):
        self.assertEqual(self.cost_evaluation.cost_requests, 0)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)

        workload = Workload([self.queries[0]])

        self.cost_evaluation.calculate_cost(workload, indexes=set())
        self.assertEqual(self.cost_evaluation.cost_requests, 1)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)
        self.assertEqual(self.connector.get_cost.call_count, 1)

        self.cost_evaluation.calculate_cost(workload, indexes=set())
        self.assertEqual(self.cost_evaluation.cost_requests, 2)
        self.assertEqual(self.cost_evaluation.cache_hits, 1)
        self.assertEqual(self.connector.get_cost.call_count, 1)

    def test_cache_hit_different_index_same_columns(self):
        self.assertEqual(self.cost_evaluation.cost_requests, 0)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)

        workload = Workload([self.queries[0]])

        self.cost_evaluation.calculate_cost(workload, set([Index([self.columns[0]])]))
        self.assertEqual(self.cost_evaluation.cost_requests, 1)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)
        self.assertEqual(self.connector.get_cost.call_count, 1)

        self.cost_evaluation.calculate_cost(workload, set([Index([self.columns[0]])]))
        self.assertEqual(self.cost_evaluation.cost_requests, 2)
        self.assertEqual(self.cost_evaluation.cache_hits, 1)
        self.assertEqual(self.connector.get_cost.call_count, 1)

    def test_no_cache_hit_unseen(self):
        self.assertEqual(self.cost_evaluation.cost_requests, 0)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)

        workload = Workload([self.queries[0]])
        index_0 = Index([self.columns[0]])

        self.cost_evaluation.calculate_cost(workload, indexes=set())
        self.assertEqual(self.cost_evaluation.cost_requests, 1)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)
        self.assertEqual(self.connector.get_cost.call_count, 1)

        self.cost_evaluation.calculate_cost(workload, set([index_0]))
        self.assertEqual(self.cost_evaluation.cost_requests, 2)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)
        self.assertEqual(self.connector.get_cost.call_count, 2)
        self.connector.simulate_index.assert_called_with(index_0)

    def test_cache_hit_non_relevant_index(self):
        self.assertEqual(self.cost_evaluation.cost_requests, 0)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)

        workload = Workload([self.queries[0]])
        index_1 = Index([self.columns[1]])

        self.cost_evaluation.calculate_cost(workload, indexes=set())
        self.assertEqual(self.cost_evaluation.cost_requests, 1)
        self.assertEqual(self.cost_evaluation.cache_hits, 0)
        self.assertEqual(self.connector.get_cost.call_count, 1)

        self.cost_evaluation.calculate_cost(workload, set([index_1]))
        self.assertEqual(self.cost_evaluation.cost_requests, 2)
        self.assertEqual(self.cost_evaluation.cache_hits, 1)
        self.assertEqual(self.connector.get_cost.call_count, 1)
        self.connector.simulate_index.assert_called_with(index_1)

    def test_which_indexes_utilized_and_cost(self):
        def _simulate_index_mock(index, store_size):
            index.hypopg_name = f"<1337>btree_{index.columns}"

        # For some reason, the database decides to only use an index for one of
        # the filters
        def _simulate_get_plan(query):
            plan = {
                "Total Cost": 17,
                "Plans": [
                    {
                        "Index Name": "<1337>btree_(C testtablea.col1,)",
                        "Filter": "(Col0 = 14)",
                    }
                ],
            }

            return plan

        query = self.queries[2]

        self.cost_evaluation.db_connector.get_plan = MagicMock(
            side_effect=_simulate_get_plan
        )
        self.cost_evaluation.what_if.simulate_index = MagicMock(
            side_effect=_simulate_index_mock
        )

        candidates = syntactically_relevant_indexes(query, max_index_width=2)
        indexes, cost = self.cost_evaluation.which_indexes_utilized_and_cost(
            query, candidates
        )
        self.assertEqual(cost, 17)
        self.assertEqual(indexes, {Index([self.columns[1]])})

        self.assertEqual(
            self.cost_evaluation.what_if.simulate_index.call_count, len(candidates)
        )
        self.cost_evaluation.db_connector.get_plan.assert_called_once_with(query)
        self.assertCountEqual(self.cost_evaluation.current_indexes, candidates)


class TestPrepareCostEvaluation(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "TestDB"

        cls.table = Table("TestTableA")
        cls.columns = [
            Column("Col0"),
            Column("Col1"),
            Column("Col2"),
            Column("Col3"),
            Column("Col4"),
        ]
        cls.table.add_columns(cls.columns)

        cls.index_0 = Index([cls.columns[0]])
        cls.index_1 = Index([cls.columns[1]])
        cls.index_2 = Index([cls.columns[2]])

    def setUp(self):
        self.mock_what_if = MockWhatIf()
        self.mock_what_if.simulate_index = MagicMock()
        self.mock_what_if.drop_simulated_index = MagicMock()

        self.cost_evaluation = CostEvaluation(MockConnector())
        self.cost_evaluation.what_if = self.mock_what_if

    def test_prepare_cost_calculation_does_nothing_empty_indexes(self):
        self.cost_evaluation.current_indexes = set()

        self.cost_evaluation._prepare_cost_calculation(set([]))
        self.mock_what_if.simulate_index.assert_not_called()
        self.mock_what_if.drop_simulated_index.assert_not_called()
        self.assertEqual(self.cost_evaluation.current_indexes, set([]))

    def test_prepare_cost_calculation_does_nothing_indexes_equal_current_indexes(self):
        self.cost_evaluation.current_indexes = set([self.index_0, self.index_1])

        self.cost_evaluation._prepare_cost_calculation([self.index_0, self.index_1])
        self.mock_what_if.simulate_index.assert_not_called()
        self.mock_what_if.drop_simulated_index.assert_not_called()
        self.assertEqual(
            self.cost_evaluation.current_indexes, set([self.index_0, self.index_1])
        )

    def test_prepare_cost_calculation_index_removed(self):
        self.cost_evaluation.current_indexes = set([self.index_0, self.index_1])

        self.cost_evaluation._prepare_cost_calculation([self.index_0])
        self.mock_what_if.simulate_index.assert_not_called()
        self.mock_what_if.drop_simulated_index.assert_called_with(self.index_1)
        self.assertEqual(self.cost_evaluation.current_indexes, set([self.index_0]))

    def test_prepare_cost_calculation_index_added(self):
        self.cost_evaluation.current_indexes = set([self.index_0])

        self.cost_evaluation._prepare_cost_calculation([self.index_0, self.index_1])
        self.mock_what_if.simulate_index.assert_called_with(
            self.index_1, store_size=False
        )
        self.mock_what_if.drop_simulated_index.assert_not_called()
        self.assertEqual(
            self.cost_evaluation.current_indexes, set([self.index_0, self.index_1])
        )

    def test_prepare_cost_calculation_index_added_and_removed(self):
        self.cost_evaluation.current_indexes = set([self.index_0, self.index_1])

        self.cost_evaluation._prepare_cost_calculation([self.index_0, self.index_2])
        self.mock_what_if.simulate_index.assert_called_with(
            self.index_2, store_size=False
        )
        self.mock_what_if.drop_simulated_index.assert_called_with(self.index_1)
        self.assertEqual(
            self.cost_evaluation.current_indexes, set([self.index_0, self.index_2])
        )

    def test_complete_cost_estimation(self):
        self.cost_evaluation.current_indexes = set([self.index_0, self.index_1])
        self.assertFalse(self.cost_evaluation.completed)

        self.cost_evaluation.complete_cost_estimation()
        self.assertTrue(self.cost_evaluation.completed)
        self.mock_what_if.drop_simulated_index.assert_any_call(self.index_0)
        self.mock_what_if.drop_simulated_index.assert_any_call(self.index_1)
        self.assertEqual(self.cost_evaluation.current_indexes, set())


if __name__ == "__main__":
    unittest.main()
