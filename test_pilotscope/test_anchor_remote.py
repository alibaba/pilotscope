import unittest
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from test_pilotscope.test_anchor_local import TestAnchorLocal


class TestAnchorAndControllerRemote(TestAnchorLocal):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config = PostgreSQLConfig(pilotscope_core_host="127.0.0.1", db_host="127.0.0.1", db_port="5432",
                                       db_user="postgres", db_user_pwd="postgres")
        self.config.db = "stats_tiny"
        self.config.enable_deep_control_remote(example_pg_bin, example_pgdata, "root", "root")
        self.data_interactor = PilotDataInteractor(self.config)
        self.db_controller = self.data_interactor.db_controller

    def test_fetch_card(self):
        super().test_fetch_card()

    def test_anchor_order(self):
        super().test_anchor_order()

    def test_shutdown(self):
        self.db_controller.shutdown()
        is_running = self.db_controller.is_running()
        self.assertFalse(is_running)
        self.db_controller.start()
        is_running = self.db_controller.is_running()
        self.assertTrue(is_running)


if __name__ == "__main__":
    unittest.main()
