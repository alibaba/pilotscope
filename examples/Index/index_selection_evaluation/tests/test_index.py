import unittest

from selection.index import Index, index_merge, index_split
from selection.workload import Column, Table


class TestIndex(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.column_0 = Column("Col0")
        cls.column_1 = Column("Col1")
        cls.column_2 = Column("Col2")

        columns = [cls.column_0, cls.column_1, cls.column_2]
        cls.table = Table("TableA")
        cls.table.add_columns(columns)

    def test_index(self):
        columns = [self.column_0, self.column_1]
        index = Index(columns)
        self.assertEqual(index.columns, tuple(columns))
        self.assertEqual(index.estimated_size, None)
        self.assertEqual(index.hypopg_name, None)

        with self.assertRaises(ValueError):
            Index([])

    def test_repr(self):
        index_0_1 = Index([self.column_0, self.column_1])
        self.assertEqual(repr(index_0_1), "I(C tablea.col0,C tablea.col1)")

    def test_index_lt(self):
        index_0 = Index([self.column_0])
        index_1 = Index([self.column_1])

        self.assertTrue(index_0 < index_1)
        self.assertFalse(index_1 < index_0)

        index_0_1_2 = Index([self.column_0, self.column_1, self.column_2])
        self.assertTrue(index_0 < index_0_1_2)
        self.assertFalse(index_0_1_2 < index_0)

        index_0_1 = Index([self.column_0, self.column_1])
        index_0_2 = Index([self.column_0, self.column_2])
        self.assertTrue(index_0_1 < index_0_2)
        self.assertFalse(index_0_2 < index_0_1)

    def test_index_eq(self):
        index_0 = Index([self.column_0])
        index_1 = Index([self.column_1])
        index_2 = Index([self.column_0])

        self.assertFalse(index_0 == index_1)
        self.assertTrue(index_0 == index_2)

        index_0_1 = Index([self.column_0, self.column_1])
        self.assertTrue(index_0_1 == Index([self.column_0, self.column_1]))

        # Check comparing object of different class
        self.assertFalse(index_0_1 == int(3))

    def test_index_column_names(self):
        index_0_1 = Index([self.column_0, self.column_1])
        column_names = index_0_1._column_names()
        self.assertEqual(column_names, ["col0", "col1"])

    def test_index_is_single_column(self):
        index_2 = Index([self.column_2])
        index_0_1_2 = Index([self.column_0, self.column_1, self.column_2])

        self.assertTrue(index_2.is_single_column())
        self.assertFalse(index_0_1_2.is_single_column())

    def test_index_table(self):
        index_0 = Index([self.column_0])

        table = index_0.table()
        self.assertEqual(table, self.table)

    def test_index_idx(self):
        index_0_1 = Index([self.column_0, self.column_1])

        index_idx = index_0_1.index_idx()
        self.assertEqual(index_idx, "tablea_col0_col1_idx")

    def test_joined_column_names(self):
        index_0_1 = Index([self.column_0, self.column_1])

        index_idx = index_0_1.joined_column_names()
        self.assertEqual(index_idx, "col0,col1")

    def test_appendable_by_other_table(self):
        column = Column("ColZ")
        table = Table("TableZ")
        table.add_column(column)
        index_on_other_table = Index([column])

        index_0 = Index([self.column_0])

        self.assertFalse(index_0.appendable_by(index_on_other_table))

    def test_appendable_by_multi_column_index(self):
        multi_column_index = Index([self.column_0, self.column_1])

        index_2 = Index([self.column_2])

        self.assertFalse(index_2.appendable_by(multi_column_index))

    def test_appendable_by_index_with_already_present_column(self):
        index_with_already_present_column = Index([self.column_0])

        index_0_1 = Index([self.column_0, self.column_1])

        self.assertFalse(index_0_1.appendable_by(index_with_already_present_column))

    def test_appendable_by(self):
        index_appendable_by = Index([self.column_2])

        index_0_1 = Index([self.column_0, self.column_1])

        self.assertTrue(index_0_1.appendable_by(index_appendable_by))

    def test_appendable_by_other_type(self):
        index_0_1 = Index([self.column_0, self.column_1])

        self.assertFalse(index_0_1.appendable_by(int(17)))

    def test_subsumes(self):
        index_0 = Index([self.column_0])
        index_0_other = Index([self.column_0])
        index_1 = Index([self.column_1])
        index_0_1 = Index([self.column_0, self.column_0])
        index_0_2 = Index([self.column_0, self.column_2])
        index_1_0 = Index([self.column_1, self.column_0])

        self.assertTrue(index_0.subsumes(index_0_other))

        self.assertFalse(index_0.subsumes(index_1))

        self.assertTrue(index_0_1.subsumes(index_0))
        self.assertFalse(index_0_1.subsumes(index_1))
        self.assertFalse(index_0_1.subsumes(index_0_2))
        self.assertFalse(index_0_1.subsumes(index_1_0))

        self.assertFalse(index_0.subsumes(index_0_1))

        self.assertFalse(index_0.subsumes(int(17)))

    def test_merge(self):
        index_0 = Index([self.column_0])
        index_1 = Index([self.column_1])
        result = index_merge(index_0, index_1)
        expected = Index([self.column_0, self.column_1])
        self.assertEqual(result, expected)

        index_0 = Index([self.column_0, self.column_1])
        index_1 = Index([self.column_1, self.column_2])
        result = index_merge(index_0, index_1)
        expected = Index([self.column_0, self.column_1, self.column_2])
        self.assertEqual(result, expected)

        index_0 = Index([self.column_0, self.column_1])
        index_1 = Index([self.column_1, self.column_0])
        result = index_merge(index_0, index_1)
        expected = Index([self.column_0, self.column_1])
        self.assertEqual(result, expected)

        # Example from Bruno's paper
        column_a = Column("a")
        column_b = Column("b")
        column_c = Column("c")
        column_d = Column("d")
        column_e = Column("e")
        column_f = Column("f")
        column_g = Column("g")

        columns = [column_a, column_b, column_c, column_d, column_e, column_f, column_g]
        table = Table("TableB")
        table.add_columns(columns)

        index_1 = Index([column_a, column_b, column_c, column_d, column_e, column_f])
        index_2 = Index([column_c, column_d, column_g, column_e])
        result = index_merge(index_1, index_2)
        expected = Index(
            [column_a, column_b, column_c, column_d, column_e, column_f, column_g]
        )
        self.assertEqual(result, expected)

    def test_split(self):
        # If there are no common columns, index splits are undefined
        index_0 = Index([self.column_0])
        index_1 = Index([self.column_1])
        result = index_split(index_0, index_1)
        expected = None
        self.assertEqual(result, expected)

        index_0 = Index([self.column_0, self.column_1])
        index_1 = Index([self.column_1])
        result = index_split(index_0, index_1)
        common_column_index = Index([self.column_1])
        residual_column_index_0 = Index([self.column_0])
        expected = {common_column_index, residual_column_index_0}
        self.assertEqual(result, expected)

        index_0 = Index([self.column_1])
        index_1 = Index([self.column_1, self.column_2])
        result = index_split(index_0, index_1)
        common_column_index = Index([self.column_1])
        residual_column_index_1 = Index([self.column_2])
        expected = {common_column_index, residual_column_index_1}
        self.assertEqual(result, expected)

        index_0 = Index([self.column_0, self.column_1])
        index_1 = Index([self.column_1, self.column_2])
        result = index_split(index_0, index_1)
        common_column_index = Index([self.column_1])
        residual_column_index_0 = Index([self.column_0])
        residual_column_index_1 = Index([self.column_2])
        expected = {
            common_column_index,
            residual_column_index_0,
            residual_column_index_1,
        }
        self.assertEqual(result, expected)

        # Example from Bruno's paper
        column_a = Column("a")
        column_b = Column("b")
        column_c = Column("c")
        column_d = Column("d")
        column_e = Column("e")
        column_f = Column("f")
        column_g = Column("g")

        columns = [column_a, column_b, column_c, column_d, column_e, column_f, column_g]
        table = Table("TableB")
        table.add_columns(columns)

        index_1 = Index([column_a, column_b, column_c, column_d, column_e, column_f])
        index_2 = Index([column_c, column_a, column_e])
        index_3 = Index([column_a, column_b, column_d, column_g])

        result = index_split(index_1, index_2)
        # expected is different from the paper, because there was an error for I_R2
        expected = {
            Index([column_a, column_c, column_e]),
            Index([column_b, column_d, column_f]),
        }
        self.assertEqual(result, expected)

        result = index_split(index_1, index_3)
        # expected is different from the paper,
        # because all columns are part of the key (there is no suffix)
        expected = {
            Index([column_a, column_b, column_d]),
            Index([column_c, column_e, column_f]),
            Index([column_g]),
        }
        self.assertEqual(result, expected)

    def test_prefixes(self):
        index = Index([self.column_0, self.column_1, self.column_2])
        result = index.prefixes()
        expected = [Index([self.column_0, self.column_1]), Index([self.column_0])]
        self.assertEqual(result, expected)

        # A single-column index has no prefixes.
        index = Index([self.column_0])
        result = index.prefixes()
        expected = []
        self.assertEqual(result, expected)


if __name__ == "__main__":
    unittest.main()
