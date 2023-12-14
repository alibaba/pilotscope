import unittest
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.Common.Index import Index
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData


class TestAnchorLocal(unittest.TestCase):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.enable_deep_control_local(example_pg_bin, example_pgdata)
        self.data_interactor = PilotDataInteractor(self.config)
        self.db_controller = DBControllerFactory.get_db_controller(self.config)
        self.sql = "select count(*) from posts as p, postlinks as pl, posthistory as ph where p.id = pl.postid and pl.postid = ph.postid and p.creationdate>=1279570117 and ph.creationdate>=1279585800 and p.score < 50;"

    def test_push_index(self):
        table = "postlinks"
        index = Index(columns=["linktypeid"], table=table, index_name="postlinks_linktypeid_idx")
        self.db_controller.drop_index(index)

        origin_index_size = self.db_controller.get_index_number(table)
        self.data_interactor.push_index([index], False)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.execute(self.sql, is_reset=False)
        self.assertTrue(self.db_controller.get_index_number(table) == origin_index_size + 1)
        self.db_controller.drop_index(index)
        self.assertTrue(self.db_controller.get_index_number(table) == origin_index_size)

    def test_push_simulated_index(self):
        table = "postlinks"
        index = Index(columns=["linktypeid"], table=table, index_name="postlinks_linktypeid_idx")

        data_interactor = PilotDataInteractor(self.config, enable_simulate_index=True)
        data_interactor.push_index([index], False)
        data_interactor.pull_estimated_cost()
        data_interactor.execute(self.sql, is_reset=False)

        simulated_index_size = data_interactor.db_controller.get_index_number(table)
        self.assertTrue(simulated_index_size == 1)

        # the simulated index will be deleted after terminating connection
        data_interactor.reset()
        simulated_index_size = data_interactor.db_controller.get_index_number(table)
        self.assertTrue(simulated_index_size == 0)

    def test_push_knob(self):
        self.data_interactor.push_knob({"max_connections": "101"})
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show max_connections;")
        print(data.records)
        self.assertEqual(data.records.values[0][0], '101')  # even reset, knob don't change

    def test_push_hint(self):
        self.data_interactor.push_hint({"enable_nestloop": "off"})
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;", is_reset=True)
        self.assertEqual(data.records.values[0][0], "off")

        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;")
        # data = self.data_interactor.execute("select pg_backend_pid();")
        print(data.records)
        self.assertEqual(data.records.values[0][0], "on")

    def test_pull_card(self):
        self.data_interactor.pull_subquery_card()
        data: PilotTransData = self.data_interactor.execute(self.sql)
        print(data.subquery_2_card)
        self.assertTrue(len(data.subquery_2_card) > 0)

    def test_pull_plan(self):
        self.data_interactor.pull_physical_plan()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.physical_plan)
        self.assertTrue(data.physical_plan is not None)

    def test_pull_cost(self):
        self.data_interactor.pull_estimated_cost()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.estimated_cost)
        self.assertTrue(data.estimated_cost is not None)

    def test_pull_buffer_cache(self):
        self.data_interactor.pull_buffercache()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.buffercache)
        self.assertTrue(data.buffercache is not None)

    def test_pull_record(self):
        self.data_interactor.pull_record()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.records)
        self.assertTrue(data.records is not None)


if __name__ == "__main__":
    unittest.main()
