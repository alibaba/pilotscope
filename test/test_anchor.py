import unittest

from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PilotConfig()
        self.config.db = "stats"
        self.config.db_type = DatabaseEnum.POSTGRESQL
        self.state_manager = PilotStateManager(self.config)
        self.sql = "select * from badges limit 10;"

    def test_fetch_card(self):
        self.state_manager.fetch_subquery_card()
        self.state_manager.execute(self.sql)


if __name__ == '__main__':
    unittest.main()
