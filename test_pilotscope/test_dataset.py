import unittest

from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.Dataset.ImdbDataset import ImdbDataset
from pilotscope.Dataset.ImdbTinyDataset import ImdbTinyDataset
from pilotscope.Dataset.StatsDataset import StatsDataset
from pilotscope.Dataset.StatsTinyDataset import StatsTinyDataset
from pilotscope.Dataset.TpcdsDataset import TpcdsDataset
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum


def test_dataset(ds: BaseDataset):
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

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config: PostgreSQLConfig = PostgreSQLConfig()
        self.config.enable_deep_control_local(example_pg_bin, example_pgdata)

    def test_load_to_stats(self):
        ds = StatsDataset(DatabaseEnum.POSTGRESQL, created_db_name="test_stats", data_dir=None)
        ds.load_to_db(self.config)
        # the config will be modified in load_to_db, so we need to get controller after that
        db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(db_controller.exist_table(table))
            db_controller.drop_table_if_exist(table)

    def test_load_to_db_stats_tiny_from_local(self):
        ds = StatsTinyDataset(DatabaseEnum.POSTGRESQL, created_db_name="test_stats_tiny")
        ds.load_to_db(self.config)
        db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(db_controller.exist_table(table))
            db_controller.drop_table_if_exist(table)

    def test_load_to_stats_remote(self):
        self.config = PostgreSQLConfig(pilotscope_core_host="127.0.0.1", db_host="127.0.0.1", db_port="5432",
                                       db_user="postgres", db_user_pwd="postgres")
        self.config.enable_deep_control_remote(example_pg_bin, example_pgdata, "root", "root")
        ds = StatsTinyDataset(DatabaseEnum.POSTGRESQL, created_db_name="stats_tiny_remote")
        ds.load_to_db(self.config)
        db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(db_controller.exist_table(table))
            db_controller.drop_table_if_exist(table)
        ds = StatsDataset(DatabaseEnum.POSTGRESQL, created_db_name="stats_remote")
        ds.load_to_db(self.config)
        db_controller = DBControllerFactory.get_db_controller(self.config)
        # the config will be modified in load_to_db, so we need to get controller again
        for table in ['badges', 'comments', 'posthistory', 'postlinks', 'posts', 'tags', 'users', 'votes']:
            self.assertTrue(db_controller.exist_table(table))
            db_controller.drop_table_if_exist(table)

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
        print("test_get_sql done")


if __name__ == '__main__':
    unittest.main()
