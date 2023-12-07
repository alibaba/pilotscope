import unittest

from pandas import DataFrame

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.data_manager = DataManager(self.config)
        self.test_table_name = "data_manager_test_table"
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)

    def test_drop_table(self):
        self.data_manager.remove_table_and_tracker(self.test_table_name)
        self.assertFalse(self.db_controller.exist_table(self.test_table_name))

    def test_create_table(self):
        data = {"name": "wlg", "age": 1}
        self.data_manager._create_table_if_absence(self.test_table_name, data)
        self.assertTrue(self.db_controller.exist_table(self.test_table_name))

    def test_save_data(self):
        self.test_drop_table()
        self.test_create_table()

        data = {"name": "name1", "age": 10}
        self.data_manager.save_data(self.test_table_name, data)
        data2 = {"name": "name2", "age": 11}
        data3 = {"name": "name3", "age": 11}
        self.data_manager.save_data_batch(self.test_table_name, [data2, data3])
        self.assertTrue(self.db_controller.get_table_row_count(self.test_table_name) == 3)

    def test_read_all(self):
        data_size = self.init_table()
        data: DataFrame = self.data_manager.read_all(self.test_table_name)
        self.assertTrue(len(data) == data_size)

    def test_read_update(self):
        data_size = self.init_table()
        data: DataFrame = self.data_manager.read_update(self.test_table_name)
        self.assertTrue(len(data) == data_size)

        # add one new rows
        write_data = {"name": "name4", "age": 11}
        self.data_manager.save_data(self.test_table_name, write_data)
        data: DataFrame = self.data_manager.read_update(self.test_table_name)
        self.assertTrue(len(data) == 1)

    def init_table(self):
        self.test_drop_table()
        self.test_create_table()
        data = [
            {"name": "name1", "age": 10},
            {"name": "name2", "age": 11},
            {"name": "name3", "age": 11}
        ]
        self.data_manager.save_data_batch(self.test_table_name, data)
        return len(data)


if __name__ == '__main__':
    unittest.main()
