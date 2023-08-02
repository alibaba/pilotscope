import unittest

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.common.Index import Index

class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        
    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.config.set_db_type(DatabaseEnum.POSTGRESQL)
        cls.table_name = "lero"
        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)
        cls.sql = "select * from badges limit 10;"
        cls.table = "badges"
        cls.test_table = "test_table"
        cls.column = "date"
        cls.db_controller.create_table_if_absences(cls.test_table, {"col_1":1, "col_2":1})
        cls.db_controller.insert(cls.test_table, {"col_1":1, "col_2":1})

    def test_explain_physical_plan(self):
        res = self.db_controller.explain_physical_plan(self.sql)
        print(res)

    def test_explain_execution_plan(self):
        res = self.db_controller.explain_execution_plan(self.sql)
        self.assertTrue("Execution Time" in res)
        print(res)

    def test_get_existed_index(self):
        res = self.db_controller.get_existed_index("badges")
        print(res)
        self.assertTrue("badges: userid" in str(res))
        print(res)

    def test_get_relation_content(self):
        res = self.db_controller.get_relation_content(self.test_table, True)
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
        print(res)

    def create_and_drop_table(self):
        test_table = "test_table_name"
        self.db_controller.create_table_if_absences(test_table, {"col":1})
        self.assertTrue(self.db_controller.exist_table(test_table))
        self.assertTrue(test_table in self.db_controller.name_2_table)
        self.db_controller.drop_table_if_existence(test_table)
        self.assertFalse(self.db_controller.exist_table(test_table))
    # def test_recover_imdb_index(self):
    #     # self.config.db = "imdbfull"
    #     self.config.db = "imdb"
    #     self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
    #     recover_imdb_index(self.db_controller)
    #     res = self.db_controller.get_all_indexes()
    #     print(res)
    @classmethod
    def tearDownClass(cls):
        cls.db_controller.drop_table_if_existence(cls.test_table)


if __name__ == '__main__':
    unittest.main()
