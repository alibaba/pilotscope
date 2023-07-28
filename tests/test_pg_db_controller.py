import unittest

from DBController.PostgreSQLController import PostgreSQLController
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig, PostgreSQLConfig
from PilotEnum import DatabaseEnum
from common.Index import Index
from examples.utils import recover_imdb_index


class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.table_name = "lero"
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
        self.sql = "select * from badges limit 10;"
        self.table = "badges"
        self.column = "date"

    def test_explain_physical_plan(self):
        res = self.db_controller.explain_physical_plan(self.sql)
        print(res)

    def test_explain_execution_plan(self):
        res = self.db_controller.explain_execution_plan(self.sql)
        print(res)

    def test_get_existed_index(self):
        res = self.db_controller.get_existed_index("badges")
        print(res)

    def test_create_index(self):
        pass

    # index_name = "test_create_index"
    #     n = self.db_controller.get_index_number(self.table)
    #     self.db_controller.create_index(None, None, None)
    #     cur_n = self.db_controller.get_index_number(self.table)
    #     self.assertEqual(cur_n, n + 1)
    #
    #     self.db_controller.drop_index(Index(columns=["date"], table="badges", index_name=index_name))
    #
    # def test_drop_index(self):
    #     index_name = "test_drop_index"
    #     index = Index(columns=["date"], table="badges", index_name=index_name)
    #     # self.db_controller.create_index(index.get_index_name(),index.table,index.columns)
    #     n = self.db_controller.get_index_number(self.table)
    #
    #     self.db_controller.drop_index(index.get_index_name())
    #     cur_n = self.db_controller.get_index_number(self.table)
    #
    #     self.assertEqual(cur_n, n - 1)
    #
    # def test_get_index_number(self):
    #     n = self.db_controller.get_index_number(self.table)
    #
    #     # add index
    #     index_name = "test_get_index_number_index"
    #     self.db_controller.create_index(None, None, None)
    #
    #     cur_n = self.db_controller.get_index_number(self.table)
    #
    #     self.assertEqual(cur_n, n + 1)
    #
    #     # drop index
    #     self.db_controller.drop_index(index_name)

    def test_get_all_indexes_byte(self):
        size = self.db_controller.get_all_indexes_byte()
        print("indexes size is {}".format(size))

    # def test_get_index_byte(self):
    #     index_name = "test_get_index_byte"
    #     self.db_controller.create_index(None, None, None)
    #     size = self.db_controller.get_index_byte(index_name)
    #     print("indexes size is {}".format(size))
    #     self.db_controller.drop_index(index_name)

    def test_get_table_index_byte(self):
        size = self.db_controller.get_table_indexes_byte(self.table)
        print("index size is {}".format(size))

    def test_get_internal_metrics(self):
        res = self.db_controller.get_internal_metrics()
        print(res)

    def test_get_all_indexes(self):
        self.config.db = "imdbfull"
        # self.config.db = "imdb"
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
        res = self.db_controller.get_all_indexes()
        print(res)

    def test_recover_imdb_index(self):
        # self.config.db = "imdbfull"
        self.config.db = "imdb"
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
        recover_imdb_index(self.db_controller)
        res = self.db_controller.get_all_indexes()
        print(res)


if __name__ == '__main__':
    unittest.main()
