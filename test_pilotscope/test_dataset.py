import unittest
from pilotscope.Dataset.ImdbDataset import ImdbDataset
from pilotscope.Dataset.StatsDataset import StatsDataset
from pilotscope.Dataset.StatsTinyDataset import StatsTinyDataset
from pilotscope.Dataset.ImdbTinyDataset import ImdbTinyDataset
from pilotscope.Dataset.TpcdsDataset import TpcdsDataset
from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.PilotEnum import DatabaseEnum

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata


def test_dataset(ds:BaseDataset):
    train_set = ds.read_train_sql()
    print("train:\n", len(train_set), train_set[0])
    test_set = ds.read_test_sql()
    print("test:\n", len(test_set), test_set[0])
    try:
        test_set_fast = ds.test_sql_fast()
        print("test(fast):\n", len(test_set_fast), test_set_fast[0])
    except FileNotFoundError:
        pass

class MyTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.enable_deep_control(example_pg_bin, example_pgdata)
        cls.config.db = "stats_loadtest"
        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)

    def test_load_to_db(self):
        ds = StatsDataset(DatabaseEnum.POSTGRESQL)
        ds.load_to_db(self.db_controller)
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(self.db_controller.exist_table(table))
            self.db_controller.drop_table_if_exist(table)

    def test_load_to_db_from_local(self):
        ds =StatsTinyDataset(DatabaseEnum.POSTGRESQL)
        ds.load_to_db(self.db_controller)
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(self.db_controller.exist_table(table))
            self.db_controller.drop_table_if_exist(table)

    def test_get_sql(self):
        ds = ImdbDataset(DatabaseEnum.POSTGRESQL)
        test_dataset(ds)
        ds = ImdbDataset(DatabaseEnum.SPARK)
        test_dataset(ds)
        ds = StatsDataset(DatabaseEnum.POSTGRESQL)
        test_dataset(ds)
        ds = StatsDataset(DatabaseEnum.SPARK)
        test_dataset(ds)
        ds = StatsTinyDataset(DatabaseEnum.POSTGRESQL)
        test_dataset(ds)
        ds = ImdbTinyDataset(DatabaseEnum.POSTGRESQL)
        test_dataset(ds)
        ds = TpcdsDataset(DatabaseEnum.POSTGRESQL)
        test_dataset(ds)
        ds = TpcdsDataset(DatabaseEnum.SPARK)
        test_dataset(ds)


if __name__ == '__main__':
    unittest.main()
