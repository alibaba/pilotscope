import os
import unittest

from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.DBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEvent import PeriodicModelUpdateEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from pilotscope.PilotTransData import PilotTransData


class ExamplePilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.model_save_dir = "../algorithm_examples/ExampleData/Example/Model"
        self.model_path = os.path.join(self.model_save_dir, self.model_name)

    def save_model(self):
        self.test_flag = "test_flag"

    def load_model(self):
        pass

    def predict(self, subquery_2_card):
        # Do inference. You can replace the cardinalities of DBMS with ML model's 
        return subquery_2_card


class ExampleCardPushHandler(CardPushHandler):

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.pilot_data_interactor = PilotDataInteractor(config)

    def acquire_injected_data(self, sql):
        self.pilot_data_interactor.pull_subquery_card()
        data: PilotTransData = self.pilot_data_interactor.execute(sql)
        assert data.subquery_2_card is not None
        return self.model.predict(data.subquery_2_card)


class ExamplePeriodicModelUpdateEvent(PeriodicModelUpdateEvent):
    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            data_manager: DataManager):
        print("IN ExamplePeriodicDbControllerEvent")


class TestScheduler(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.sql = "select date from badges where date=1406838696"

    def test_scheduler(self):
        config = self.config
        scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
        model = ExamplePilotModel("test_model")
        model.save_model()
        model = ExamplePilotModel("test_model")
        model.load_model()

        handler = ExampleCardPushHandler(model, config)
        scheduler.register_custom_handlers([handler])
        event = ExamplePeriodicModelUpdateEvent(config, 2, execute_on_init=True)
        scheduler.register_events([event])

        test_scheduler_table = "test_scheduler_table"
        scheduler.register_required_data(test_scheduler_table, pull_buffer_cache=True, pull_estimated_cost=True,
                                         pull_execution_time=True, pull_physical_plan=True,
                                         pull_records=True, pull_subquery_2_cards=True)
        scheduler.init()
        data = scheduler.execute(self.sql)
        print(data)

        config.db = "PilotScopeUserData"
        db_controller = DBControllerFactory.get_db_controller(config, echo=True)
        res = db_controller.get_table_row_count(test_scheduler_table)
        self.assertAlmostEqual(res, 1)

        scheduler.execute(self.sql)

        db_controller.drop_table_if_exist(test_scheduler_table)


if __name__ == '__main__':
    unittest.main()
