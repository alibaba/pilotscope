import unittest
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from test_pilotscope.test_pg.test_data_interactor import TestDataInteractor


class TestDataInteractorRemote(TestDataInteractor):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName, skip_init=True)
        self.config = PostgreSQLConfig(pilotscope_core_host="127.0.0.1", db_host="127.0.0.1", db_port="5432",
                                       db_user="pilotscope", db_user_pwd="pilotscope")
        self.config.db = "stats_tiny"
        self.config.enable_deep_control_remote(example_pg_bin, example_pgdata, "pilotscope", "pilotscope")

        self.data_interactor = PilotDataInteractor(self.config)
        self.db_controller = DBControllerFactory.get_db_controller(self.config)


if __name__ == "__main__":
    unittest.main()
