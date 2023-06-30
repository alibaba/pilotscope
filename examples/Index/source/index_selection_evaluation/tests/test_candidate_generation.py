import unittest
from unittest.mock import MagicMock

from selection.candidate_generation import (
    candidates_per_query,
    syntactically_relevant_indexes,
)
from selection.index import Index
from selection.workload import Column, Query, Table, Workload
from tests.mock_connector import query_0, query_1


class TestCandidateGeneration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.column_0 = Column("Col0")
        cls.column_1 = Column("Col1")
        cls.column_2 = Column("Col2")

        cls.table = Table("Table0")
        cls.table.add_columns([cls.column_0, cls.column_1, cls.column_2])

        cls.column_0_table_1 = Column("Col0")
        cls.table_1 = Table("Table1")
        cls.table_1.add_column(cls.column_0_table_1)
        cls.query_0 = Query(
            17,
            """SELECT * FROM Table0 as t0, Table1 as t1 WHERE t0.Col0 = 1"
                AND t0.Col1 = 2 AND t0.Col2 = 3 AND t1.Col0 = 17;""",
            [cls.column_0, cls.column_1, cls.column_2, cls.column_0_table_1],
        )

    def test_syntactically_relevant_indexes(self):
        indexes = syntactically_relevant_indexes(self.query_0, max_index_width=3)
        self.assertIn(Index([self.column_0_table_1]), indexes)
        self.assertIn(Index([self.column_0]), indexes)
        self.assertIn(Index([self.column_1]), indexes)
        self.assertIn(Index([self.column_2]), indexes)
        self.assertIn(Index([self.column_0, self.column_1]), indexes)
        self.assertIn(Index([self.column_0, self.column_2]), indexes)
        self.assertIn(Index([self.column_1, self.column_0]), indexes)
        self.assertIn(Index([self.column_1, self.column_2]), indexes)
        self.assertIn(Index([self.column_2, self.column_0]), indexes)
        self.assertIn(Index([self.column_2, self.column_1]), indexes)
        self.assertIn(Index([self.column_0, self.column_1, self.column_2]), indexes)
        self.assertIn(Index([self.column_0, self.column_2, self.column_1]), indexes)
        self.assertIn(Index([self.column_1, self.column_0, self.column_2]), indexes)
        self.assertIn(Index([self.column_1, self.column_2, self.column_0]), indexes)
        self.assertIn(Index([self.column_2, self.column_0, self.column_1]), indexes)
        self.assertIn(Index([self.column_2, self.column_1, self.column_0]), indexes)

        result = syntactically_relevant_indexes(query_0, max_index_width=2)
        self.assertEqual(len(result), 1)

        result = syntactically_relevant_indexes(query_1, max_index_width=2)
        self.assertEqual(len(result), 9)

        result = syntactically_relevant_indexes(query_1, max_index_width=3)
        self.assertEqual(len(result), 15)

    def test_candidates_per_query(self):
        MAX_INDEX_WIDTH = 2
        query_1 = Query(18, """SELECT * FROM 1;""")
        workload = Workload([self.query_0, query_1])

        syntactically_relevant_indexes_mock = MagicMock(
            return_value=syntactically_relevant_indexes
        )

        result = candidates_per_query(
            workload,
            max_index_width=MAX_INDEX_WIDTH,
            candidate_generator=syntactically_relevant_indexes_mock,
        )

        self.assertEqual(len(result), len(workload.queries))
        syntactically_relevant_indexes_mock.assert_called_with(query_1, MAX_INDEX_WIDTH)
        syntactically_relevant_indexes_mock.assert_any_call(self.query_0, MAX_INDEX_WIDTH)
