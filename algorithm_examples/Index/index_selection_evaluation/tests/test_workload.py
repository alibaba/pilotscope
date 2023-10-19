import unittest

from mock_connector import column_A_0, column_A_1, column_A_2, query_0, query_1

from selection.index import Index
from selection.workload import Column, Query, Table, Workload


class TestTable(unittest.TestCase):
    def test_table(self):
        table = Table("TableA")
        self.assertEqual(table.name, "tablea")
        self.assertEqual(table.columns, [])

    def test_table_add_column(self):
        table = Table("TableA")
        column_1 = Column("ColA")
        table.add_column(column_1)

        self.assertEqual(table.columns, [column_1])
        self.assertEqual(column_1.table, table)

        column_2 = Column("ColB")
        column_3 = Column("ColC")
        table.add_columns([column_2, column_3])

        self.assertEqual(table.columns, [column_1, column_2, column_3])
        self.assertEqual(column_2.table, table)
        self.assertEqual(column_3.table, table)

    def test_table_repr(self):
        table = Table("TableA")
        self.assertEqual(repr(table), "tablea")

    def test_table_eq_no_columns(self):
        table_1 = Table("TableA")
        table_2 = Table("TableA")
        table_3 = Table("TableB")
        self.assertTrue(table_1 == table_2)
        self.assertFalse(table_1 == table_3)

        # Check comparing object of different class
        self.assertFalse(table_1 == int(3))

    def test_table_eq_with_columns(self):
        table_1 = Table("TableA")
        table_1.add_column(Column("ColA"))
        table_2 = Table("TableA")
        self.assertFalse(table_1 == table_2)

        table_2.add_column(Column("ColA"))
        self.assertTrue(table_1 == table_2)

        table_1.add_column(Column("ColB"))
        table_1.add_column(Column("ColC"))
        self.assertFalse(table_1 == table_2)

        table_2.add_column(Column("ColB"))
        table_2.add_column(Column("ColC"))
        self.assertTrue(table_1 == table_2)

        # Testing same column names, but different order
        table_3 = Table("TableA")
        table_3.add_column(Column("ColC"))
        table_3.add_column(Column("ColB"))
        table_3.add_column(Column("ColA"))
        self.assertFalse(table_1 == table_3)


class TestColumn(unittest.TestCase):
    def test_column(self):
        column = Column(name="ColA")
        self.assertEqual(column.name, "cola")
        self.assertIsNone(column.table)

    # Even though this is tested in test_table_add_column above,
    # it is tested from another angle and another developer might
    # expect this here.
    def test_column_added_to_table(self):
        column = Column(name="ColA")
        table = Table("TableA")
        table.add_column(column)

        self.assertEqual(column.table, table)

    def test_column_repr(self):
        column = Column(name="ColA")
        table = Table("TableA")
        table.add_column(column)
        self.assertEqual(repr(column), "C tablea.cola")

    def test_column_eq(self):
        table_1 = Table("TableA")
        table_2 = Table("TableA")
        column_1 = Column(name="ColA")
        column_2 = Column(name="ColA")
        column_3 = Column(name="ColB")

        # Column name equal but table (for both) is None
        with self.assertRaises(AssertionError):
            column_1 == column_2

        # Column name different but table (for both) is None
        with self.assertRaises(AssertionError):
            column_1 == column_3

        table_1.add_column(column_1)

        # Column name equal but table of column_2 is None
        with self.assertRaises(AssertionError):
            column_1 == column_2

        # Column name equal but table of column_2 is None
        with self.assertRaises(AssertionError):
            column_2 == column_1

        table_2.add_column(column_2)
        self.assertTrue(column_1 == column_2)

        table_2.add_column(column_3)
        self.assertFalse(column_1 == column_3)

        # Check comparing object of different class
        self.assertFalse(column_1 == int(3))

    def test_column_lt(self):
        column_1 = Column(name="ColA")
        column_2 = Column(name="ColA")
        column_3 = Column(name="ColB")

        self.assertFalse(column_1 < column_2)
        self.assertTrue(column_1 < column_3)


class TestQuery(unittest.TestCase):
    def test_query(self):
        query = Query(17, "SELECT * FROM lineitem;")
        self.assertEqual(query.nr, 17)
        self.assertEqual(query.text, "SELECT * FROM lineitem;")
        self.assertEqual(query.columns, [])

        column_1 = Column(name="ColA")
        column_2 = Column(name="ColB")
        query_2 = Query(18, "SELECT * FROM nation;", columns=[column_1, column_2])
        self.assertEqual(query_2.nr, 18)
        self.assertEqual(query_2.text, "SELECT * FROM nation;")
        self.assertEqual(query_2.columns, [column_1, column_2])

    def test_query_repr(self):
        query = Query(17, "SELECT * FROM lineitem;")
        self.assertEqual(repr(query), "Q17")


class TestWorkload(unittest.TestCase):
    def test_workload(self):
        query_1 = Query(17, "SELECT * FROM TableA;")
        query_2 = Query(18, "SELECT * FROM nation;")

        workload = Workload([query_1, query_2])
        self.assertEqual(workload.queries, [query_1, query_2])

    def test_workload_indexable_columns(self):
        table = Table("TableA")
        column_1 = Column(name="ColA")
        column_2 = Column(name="ColB")
        column_3 = Column(name="ColC")
        table.add_column(column_1)
        table.add_column(column_2)
        table.add_column(column_3)

        query_1 = Query(
            17,
            "SELECT * FROM TableA WHERE ColA = 4 AND ColB = 5;",
            columns=[column_1, column_2],
        )
        query_2 = Query(
            18,
            "SELECT * FROM TableA WHERE ColA = 3 AND ColC = 2;",
            columns=[column_1, column_3],
        )

        workload = Workload([query_1, query_2])
        indexable_columns = workload.indexable_columns()
        self.assertEqual(
            sorted(indexable_columns), sorted([column_1, column_2, column_3])
        )

    def test_potential_indexes(self):
        index_set_1 = set([Index([column_A_0])])
        index_set_2 = set([Index([column_A_0]), Index([column_A_1]), Index([column_A_2])])

        self.assertEqual(
            set(Workload([query_0]).potential_indexes()),
            index_set_1,
        )
        self.assertEqual(
            set(Workload([query_1]).potential_indexes()),
            index_set_2,
        )
        self.assertEqual(
            set(Workload([query_0, query_1]).potential_indexes()),
            index_set_2,
        )


if __name__ == "__main__":
    unittest.main()
