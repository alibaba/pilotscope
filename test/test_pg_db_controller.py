import unittest

from DBController.PostgreSQLController import PostgreSQLController
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.table_name = "lero"
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)
        self.sql = "select * from badges limit 10;"

    def test_explain_physical_plan(self):
        res = self.db_controller.explain_physical_plan(self.sql)
        print(res)

    def test_explain_execution_plan(self):
        res = self.db_controller.explain_execution_plan(self.sql)
        print(res)


if __name__ == '__main__':
    unittest.main()
