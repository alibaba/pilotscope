import unittest
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from test_pilotscope.test_anchor_local import TestAnchorLocal


class TestAnchorRemote(TestAnchorLocal):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config = PostgreSQLConfig(pilotscope_core_host="127.0.0.1", db_host="127.0.0.1", db_port="5432",
                                       db_user="postgres", db_user_pwd="postgres")
        self.config.db = "stats_tiny"
        self.config.enable_deep_control_remote(example_pg_bin, example_pgdata,"root","root")
        self.data_interactor = PilotDataInteractor(self.config)

    def test_fetch_card(self):
        super().test_fetch_card()

    def test_anchor_order(self):
        super().test_anchor_order()


if __name__ == "__main__":
    unittest.main()
