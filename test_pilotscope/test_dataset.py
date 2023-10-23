import unittest
from pilotscope.Dataset.ImdbDataset import ImdbDataset
from pilotscope.PilotEnum import DatabaseEnum

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig


class MyTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "imdb_loadtest"
        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)

    def test_load_to_db(self):
        return
        # It is very time-consuming(about 10 min). Delete 'return' if you really want to test it.
        ds = ImdbDataset(DatabaseEnum.POSTGRESQL)
        ds.load_to_db(self.db_controller)

    def test_get_sql(self):
        ds = ImdbDataset(DatabaseEnum.POSTGRESQL)
        train_set = ds.read_train_sql()
        print("train:\n", len(train_set), train_set[0])
        test_set = ds.read_test_sql()
        print("test:\n", len(test_set), test_set[0])
        test_set_fast = ds.test_sql_fast()
        print("test(fast):\n", len(test_set_fast), test_set_fast[0])

        ds.use_db_type = DatabaseEnum.SPARK
        train_set = ds.read_train_sql()
        print("train:\n", len(train_set), train_set[0])
        test_set = ds.read_test_sql()
        print("test:\n", len(test_set), test_set[0])
        test_set_fast = ds.test_sql_fast()
        print("test(fast):\n", len(test_set_fast), test_set_fast[0])


if __name__ == '__main__':
    unittest.main()
