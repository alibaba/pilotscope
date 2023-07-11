import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__)), "common"))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__)), "components"))

import unittest

from DBController.PostgreSQLController import PostgreSQLController
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from common.Index import Index


class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PilotConfig()
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
        index_name = "test_create_index"
        n = self.db_controller.get_index_number(self.table)
        self.db_controller.create_index(None, None, None)
        cur_n = self.db_controller.get_index_number(self.table)
        self.assertEqual(cur_n, n + 1)

        self.db_controller.drop_index(Index(columns=["date"], table="badges", index_name=index_name))

    def test_drop_index(self):
        index_name = "test_drop_index"
        self.db_controller.create_index(None, None, None)
        n = self.db_controller.get_index_number(self.table)

        self.db_controller.drop_index(Index(columns=["date"], table="badges", index_name=index_name))
        cur_n = self.db_controller.get_index_number(self.table)

        self.assertEqual(cur_n, n - 1)

    def test_get_index_number(self):
        n = self.db_controller.get_index_number(self.table)

        # add index
        index_name = "test_get_index_number_index"
        self.db_controller.create_index(None, None, None)

        cur_n = self.db_controller.get_index_number(self.table)

        self.assertEqual(cur_n, n + 1)

        # drop index
        self.db_controller.drop_index(index_name)

    def test_get_all_indexes_byte(self):
        size = self.db_controller.get_all_indexes_byte()
        print("indexes size is {}".format(size))

    def test_get_index_byte(self):
        index_name = "test_get_index_byte"
        self.db_controller.create_index(None, None, None)
        size = self.db_controller.get_index_byte(index_name)
        print("indexes size is {}".format(size))
        self.db_controller.drop_index(index_name)

    def test_get_table_index_byte(self):
        size = self.db_controller.get_table_indexes_byte(self.table)
        print("index size is {}".format(size))


if __name__ == '__main__':
    unittest.main()
