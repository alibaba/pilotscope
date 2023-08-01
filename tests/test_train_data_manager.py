import unittest

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Dao.PilotUserDataManager import PilotUserDataManager
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.Dao.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.db = "PilotScopeMeta"
        self.controller = PostgreSQLController(self.config, allow_to_create_db=True)
        self.train_data_manager = PilotTrainDataManager(self.config)
        self.table_name = "lero"

    def test_create_table(self):
        data = {"name": "wlg", "age": 10}
        self.train_data_manager._create_table_if_absence(self.table_name, data)

    def test_save_data(self):
        data = {"name": "wlg", "age": 10}
        self.train_data_manager.save_data(self.table_name, data)

    def test_count(self):
        print("row count is {}".format(self.train_data_manager.get_table_row_count(self.table_name)))

    def test_read_all(self):
        res = self.train_data_manager.read_all(self.table_name)
        print(res)

    def test_read_update(self):
        res = self.train_data_manager.read_update(self.table_name)
        print(res)

    def test_read_data_visit_count(self):
        table = "lero"
        user_data_dao = PilotUserDataManager(self.config)
        print(user_data_dao.read_training_data_visit_id(table))

    def test_set_data_visit_count(self):
        table = "lero"
        user_data_dao = PilotUserDataManager(self.config)
        user_data_dao.update_training_data_visit_id(table, 0)


if __name__ == '__main__':
    unittest.main()
