import unittest

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.index import Index
from selection.utils import (
    b_to_mb,
    get_utilized_indexes,
    indexes_by_table,
    mb_to_b,
    s_to_ms,
)
from selection.workload import Column, Query, Table, Workload


class TestSelectionUtilsGenerator(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.column_a_0 = Column("Col0")
        cls.column_a_1 = Column("Col1")
        cls.table_a = Table("TableA")
        cls.table_a.add_columns([cls.column_a_0, cls.column_a_1])

        cls.column_b_0 = Column("Col0")
        cls.table_b = Table("TableB")
        cls.table_b.add_columns([cls.column_b_0])

        cls.index_0 = Index([cls.column_a_0])
        cls.index_1 = Index([cls.column_b_0])
        cls.index_2 = Index([cls.column_a_1])

    def test_b_to_mb(self):
        byte = 17000000
        expected_megabyte = 17

        self.assertEqual(b_to_mb(byte), expected_megabyte)

    def test_mb_to_b(self):
        megabyte = 5
        expected_byte = 5000000

        self.assertEqual(mb_to_b(megabyte), expected_byte)

    def test_s_to_ms(self):
        seconds = 17
        expected_milliseconds = 17000

        self.assertEqual(s_to_ms(seconds), expected_milliseconds)

    def test_indexes_by_table(self):
        empty_index_set = []
        expected = {}
        self.assertEqual(indexes_by_table(empty_index_set), expected)

        index_set = [self.index_0, self.index_1, self.index_2]
        expected = {
            self.table_a: [self.index_0, self.index_2],
            self.table_b: [self.index_1],
        }
        self.assertEqual(indexes_by_table(index_set), expected)

    def test_get_utilized_indexes(self):
        class CostEvaluationMock:
            def which_indexes_utilized_and_cost(_, query, indexes):
                if query.nr == 0:
                    return [{self.index_0}, 17]
                if query.nr == 1:
                    return [{self.index_0, self.index_2}, 14]

            def calculate_cost(_, workload, indexes):
                assert len(workload.queries) == 1, (
                    "get_utilized_indexes' calculate_cost_mock should not be "
                    "called with workloads that contain more than one query"
                )
                assert indexes == [], (
                    "get_utilized_indexes' calculate_cost_mock should not be "
                    "called with indexes"
                )

                query = workload.queries[0]

                if query.nr == 0:
                    return 170
                if query.nr == 1:
                    return 140

        query_0 = Query(0, "SELECT * FROM tablea WHERE col0 = 4;", [self.column_a_0])
        query_1 = Query(
            1,
            (
                "SELECT * FROM tablea as a, tableb as b WHERE a.col0 = 4 AND "
                "a.col1 = 17AND b.col0 = 3;"
            ),
            [self.column_a_0, self.column_a_1, self.column_b_0],
        )
        workload = Workload([query_0, query_1])
        candidates = candidates_per_query(workload, 2, syntactically_relevant_indexes)

        utilized_indexes, query_details = get_utilized_indexes(
            workload, candidates, CostEvaluationMock()
        )
        self.assertEqual(query_details, {})
        self.assertEqual(utilized_indexes, {self.index_0, self.index_2})

        expected_first_result = {
            "cost_without_indexes": 170,
            "cost_with_indexes": 17,
            "utilized_indexes": {self.index_0},
        }
        expected_second_result = {
            "cost_without_indexes": 140,
            "cost_with_indexes": 14,
            "utilized_indexes": {self.index_0, self.index_2},
        }
        utilized_indexes, query_details = get_utilized_indexes(
            workload, candidates, CostEvaluationMock(), detailed_query_information=True
        )
        self.assertEqual(query_details[query_0], expected_first_result)
        self.assertEqual(query_details[query_1], expected_second_result)
        self.assertEqual(utilized_indexes, {self.index_0, self.index_2})
