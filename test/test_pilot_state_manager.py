import unittest

from DBController.PostgreSQLController import PostgreSQLController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        self.config = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        super().__init__(methodName)

    def test_state_manager(self):
        state_manager1 = PilotStateManager(self.config)
        state_manager1.fetch_physical_plan()
        state_manager1.fetch_execution_time()
        state_manager1.fetch_subquery_card()
        result = state_manager1.execute("select * from badges limit 1")
        print(result)


if __name__ == '__main__':
    unittest.main()
