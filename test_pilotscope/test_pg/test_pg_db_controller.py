import unittest

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.Common.Index import Index


class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.table_name = "lero"
        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)
        cls.sql = "select * from badges limit 10;"
        cls.table = "badges"
        cls.test_table = "test_table"
        cls.column = "date"
        cls.db_controller.create_table_if_absences(cls.test_table, {"col_1": 1, "col_2": 1})
        cls.db_controller.insert(cls.test_table, {"col_1": 1, "col_2": 1})

    def test_connection(self):
        self.db_controller._connect_if_loss()
        print("connection ok")

    def test_create_table(self):
        example_data = {"col_1": {1: "string"}, "col_2": [1, 2, 3], "col_3": 0.1, "col_4": "string"}
        table = "new_table"
        self.db_controller.create_table_if_absences(table, example_data)
        # KNOWN ISSUE: Although create_table_if_absences can handle dict and list, insert can not handle them
        # self.db_controller.insert(table,example_data)
        self.db_controller.drop_table_if_exist(table)
        self.db_controller.create_table_if_absences(table, {"col_1": 1, "col_2": 1}, primary_key_column="col_1")
        self.assertTrue(self.db_controller.exist_table(table))
        self.db_controller.drop_table_if_exist(table)

    def test_get_table_column_name(self):
        res = self.db_controller.get_table_columns(self.table)
        print(res)
        self.assertTrue(res == ['id', 'userid', 'date'])
        res = self.db_controller.get_table_columns(self.table)
        self.assertTrue(res == ['id', 'userid', 'date'])

    def test_explain_physical_plan(self):
        res = self.db_controller.explain_physical_plan(self.sql)
        print(res)

    def test_explain_execution_plan(self):
        res = self.db_controller.explain_execution_plan(self.sql)
        self.assertTrue("Execution Time" in res)
        print(res)

    def test_get_existed_index(self):
        res = self.db_controller.get_existed_indexes("badges")
        print(res)
        self.assertTrue("badges: userid" in str(res))
        print(res)

    def test_create_drop_index(self):
        index_name = "test_create_index"
        n = self.db_controller.get_index_number(self.table)
        index = Index(columns=[self.column], table=self.table, index_name=index_name)
        self.db_controller.create_index(index)
        cur_n = self.db_controller.get_index_number(self.table)
        self.assertEqual(cur_n, n + 1)

        self.db_controller.drop_index(index)
        cur_n = self.db_controller.get_index_number(self.table)
        self.assertEqual(cur_n, n)

    def test_get_all_indexes_byte(self):
        size = self.db_controller.get_all_indexes_byte()
        print("indexes size is {}".format(size))

    def test_get_index_byte(self):
        index_name = "test_get_index_byte"
        index = Index(columns=["col_1"], table=self.test_table, index_name=index_name)
        self.db_controller.create_index(index)
        size = self.db_controller.get_index_byte(index)
        print("indexes size is {}".format(size))
        self.db_controller.drop_index(index)

    def test_get_table_index_byte(self):
        size = self.db_controller.get_table_indexes_byte(self.table)
        print("index size is {}".format(size))

    def test_get_all_indexes(self):
        res = self.db_controller.get_all_indexes()
        print(res, len(res))
        self.assertTrue(len(res) == 12)

    def create_and_drop_table(self):
        test_table = "test_table_name"
        self.db_controller.create_table_if_absences(test_table, {"col": 1})
        self.assertTrue(self.db_controller.exist_table(test_table))
        # self.assertTrue(test_table in self.db_controller.name_2_table)
        self.db_controller.drop_table_if_exist(test_table)
        self.assertFalse(self.db_controller.exist_table(test_table))

    # def test_recover_imdb_index(self):
    #     # self.config.db = "imdbfull"
    #     self.config.db = "imdb"
    #     self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
    #     recover_imdb_index(self.db_controller)
    #     res = self.db_controller.get_all_indexes()
    #     print(res)
    def test_get_column_number_of_distinct_value_min_max_count(self):
        res = self.db_controller.get_number_of_distinct_value(self.table, self.column)
        print(res)
        self.assertTrue(res == 784)
        res = self.db_controller.get_column_max(self.table, self.column)
        print(res)
        self.assertTrue(res == 1410631710)
        res = self.db_controller.get_column_min(self.table, self.column)
        print(res)
        self.assertTrue(res == 1279568349)
        res = self.db_controller.get_table_row_count(self.table)
        print(res)
        self.assertTrue(res == 798)

    def test_get_table_names(self):
        res = self.db_controller.get_all_table_names()
        print(res)
        for x in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(x in res, res)

    @classmethod
    def tearDownClass(cls):
        cls.db_controller.drop_table_if_exist(cls.test_table)


if __name__ == '__main__':
    unittest.main()
