import unittest

from pilotscope.DataFetcher.PilotStateManager import PilotStateManager
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.db_type = DatabaseEnum.POSTGRESQL
        self.state_manager = PilotStateManager(self.config)
        self.sql = "select * from badges limit 10;"

    def test_fetch_card(self):
        self.state_manager.fetch_subquery_card()
        res = self.state_manager.execute(self.sql)
        print(res)


if __name__ == '__main__':
    unittest.main()
