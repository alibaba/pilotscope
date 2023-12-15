import unittest

from pilotscope.Common.Index import Index
from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig


class TestPostgreSQLDBController(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.table = "badges"
        cls.column = "date"
        cls.new_table = "test_postgresql_db_controller_table"
        cls.sql = "select * from badges limit 10;"

        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)
        cls.db_controller.create_table_if_absences(cls.new_table, {"col_1": 1, "col_2": 1})
        cls.db_controller.insert(cls.new_table, {"col_1": 1, "col_2": 1})

    def test_connection(self):
        self.db_controller._connect_if_loss()
        print("connection ok")

    def test_set_hint(self):
        # this has been tested in test_data_interactor.py
        pass

    def test_create_drop_table(self):
        example_data = {"col_1": {1: "string"}, "col_2": [1, 2, 3], "col_3": 0.1, "col_4": "string"}
        table = "new_table"
        self.db_controller.create_table_if_absences(table, example_data)
        self.db_controller.drop_table_if_exist(table)
        self.assertFalse(self.db_controller.exist_table(table))
        self.db_controller.create_table_if_absences(table, {"col_1": 1, "col_2": 1}, primary_key_column="col_1")
        self.assertTrue(self.db_controller.exist_table(table))
        self.db_controller.drop_table_if_exist(table)

    def test_insert(self):
        example_data = {"col_1": 0.1, "col_2": "string"}
        table = "new_table"
        self.db_controller.create_table_if_absences(table, example_data)
        self.db_controller.insert(table, example_data)
        self.assertEqual(self.db_controller.get_table_row_count(table), 1)
        self.db_controller.drop_table_if_exist(table)

    def test_get_table_column_name(self):
        res = self.db_controller.get_table_columns(self.table)
        print(res)
        self.assertTrue(res == ['id', 'userid', 'date'])

    def test_explain_physical_plan(self):
        plan = self.db_controller.explain_physical_plan(self.sql)
        print(plan)
        self.assertTrue(plan is not None and "Planning Time" in plan)

    def test_explain_execution_plan(self):
        plan = self.db_controller.explain_execution_plan(self.sql)
        self.assertTrue(plan is not None and "Execution Time" in plan)
        print(plan)

    def test_get_estimated_cost(self):
        cost = self.db_controller.get_estimated_cost(self.sql)
        print(cost)
        self.assertTrue(cost is not None)

    def test_get_buffercache(self):
        cache = self.db_controller.get_buffercache()
        print(cache)
        self.assertTrue(cache is not None)

    def test_shutdown(self):
        pass

    def test_start(self):
        pass

    def test_is_running(self):
        pass

    def test_write_knob_to_file(self):
        pass

    def test_recover_config(self):
        pass

    def test_backup_config(self):
        pass

    def test_get_existed_index(self):
        res = self.db_controller.get_existed_indexes("badges")
        print(res)
        self.assertTrue("badges: userid" in str(res))

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

    def test_drop_all_indexes(self):
        # cancel the test
        pass

    def test_get_all_indexes_byte(self):
        size = self.db_controller.get_all_indexes_byte()

        total_size = 0
        tables = self.db_controller.get_all_table_names()
        for table in tables:
            total_size += self.db_controller.get_table_indexes_byte(table)
        self.assertTrue(size == total_size)

    def test_get_index_byte(self):
        index_name = "test_get_index_byte"
        index = Index(columns=["col_1"], table=self.new_table, index_name=index_name)
        self.db_controller.create_index(index)
        size = self.db_controller.get_index_byte(index)
        print("indexes size is {}".format(size))
        self.assertTrue(size > 0)
        self.db_controller.drop_index(index)

    def test_get_table_index_byte(self):
        size = self.db_controller.get_table_indexes_byte(self.table)
        self.assertTrue(size > 0)
        print("index size is {}".format(size))

    def test_get_all_indexes(self):
        res = self.db_controller.get_all_indexes()
        print(res, len(res))
        self.assertTrue(len(res) == 12)

    # def test_recover_imdb_index(self):
    #     # self.config.db = "imdbfull"
    #     self.config.db = "imdb"
    #     self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
    #     recover_imdb_index(self.db_controller)
    #     res = self.db_controller.get_all_indexes()
    #     print(res)

    def test_get_number_of_distinct_value(self):
        res = self.db_controller.get_number_of_distinct_value(self.table, self.column)
        self.assertTrue(res == 784)

    def test_get_table_row_count(self):
        res = self.db_controller.get_table_row_count(self.table)
        self.assertTrue(res == 798)

    def test_get_column_max(self):
        res = self.db_controller.get_column_max(self.table, self.column)
        print(res)
        self.assertTrue(res == 1410631710)

    def test_get_column_min(self):
        res = self.db_controller.get_column_min(self.table, self.column)
        print(res)
        self.assertTrue(res == 1279568349)

    def test_get_table_names(self):
        res = self.db_controller.get_all_table_names()
        print(res)
        for x in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(x in res, res)

    @classmethod
    def tearDownClass(cls):
        cls.db_controller.drop_table_if_exist(cls.new_table)


if __name__ == '__main__':
    unittest.main()
