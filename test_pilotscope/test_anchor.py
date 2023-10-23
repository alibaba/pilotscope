import unittest

from algorithm_examples.ExampleConfig import example_pg_ctl, example_pgdata, example_db_config_path, \
    example_backup_db_config_path
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_knob_config(example_pg_ctl, example_pgdata, example_db_config_path,
                                    example_backup_db_config_path)
        self.data_interactor = PilotDataInteractor(self.config)
        self.sql = "select count(*) from posts as p, postlinks as pl, posthistory as ph where p.id = pl.postid and pl.postid = ph.postid and p.creationdate>=1279570117 and ph.creationdate>=1279585800 and p.score < 50;"

    def test_fetch_card(self):
        self.data_interactor.pull_subquery_card()
        res = self.data_interactor.execute(self.sql)
        print(res)

    def test_anchor_order(self):
        self.data_interactor.push_knob({"max_connections": "101"})
        self.data_interactor.push_hint({"enable_nestloop": "off"})
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;", is_reset=True)
        # data = self.data_interactor.execute("select pg_backend_pid();", is_reset=True)
        print(data.records)
        self.assertEqual(data.records.values[0][0], "off")
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;")
        # data = self.data_interactor.execute("select pg_backend_pid();")
        print(data.records)
        self.assertEqual(data.records.values[0][0], "on")
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show max_connections;")
        print(data.records)
        self.assertEqual(data.records.values[0][0], '101')  # even reset, knob don't change

        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first


if __name__ == "__main__":
    unittest.main()
