import unittest

from DBController.PostgreSQLController import PostgreSQLController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from common.Index import Index


class MyTestCase(unittest.TestCase):

    def setUp(self):
        self.config = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.state_manager = PilotStateManager(self.config)

    def test_state_manager(self):
        self.state_manager.fetch_physical_plan()
        self.state_manager.fetch_execution_time()
        self.state_manager.fetch_subquery_card()
        result = self.state_manager.execute("select * from badges limit 1")
        print(result)

    def test_index(self):
        Index("")
        self.state_manager.set_index()


if __name__ == '__main__':
    unittest.main()
