import unittest
import os

from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.DBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import EventEnum
from pilotscope.PilotEvent import PeriodicDbControllerEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotTransData import PilotTransData


class ExamplePilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.model_save_dir = "../examples/ExampleData/Example/Model"
        self.model_path = os.path.join(self.model_save_dir, self.model_name)

    def _save_user_model(self, user_model):
        self.test_flag = "test_flag"

    def _load_user_model(self):
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


class ExamplePeriodicDbControllerEvent(PeriodicDbControllerEvent):
    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):
        print("IN ExamplePeriodicDbControllerEvent")


class MyTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.set_db("stats_tiny")
        cls.sql = "select date from badges where date=1406838696"

    def test_scheduler(self):
        config = self.config
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        model = ExamplePilotModel("test_model")
        model.save()
        model = ExamplePilotModel("test_model")
        model.load()

        handler = ExampleCardPushHandler(model, config)
        scheduler.register_anchor_handler(handler)
        event = ExamplePeriodicDbControllerEvent(config, 2, True)
        scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, event)

        test_scheduler_table = "test_scheduler_table"
        scheduler.register_collect_data(test_scheduler_table, pull_buffer_cache=True, pull_estimated_cost=True,
                                        pull_execution_time=True, pull_logical_plan=True, pull_physical_plan=True,
                                        pull_records=True, pull_subquery_2_cards=True)
        scheduler.init()
        data = scheduler.simulate_db_console(self.sql)
        print(data)

        config.set_db("PilotScopeUserData")
        db_controller = DBControllerFactory.get_db_controller(config, echo=True)
        res = db_controller.get_table_row_count(test_scheduler_table)
        self.assertAlmostEqual(res, 1)

        scheduler.simulate_db_console(self.sql)

        db_controller.drop_table_if_existence(test_scheduler_table)


if __name__ == '__main__':
    unittest.main()
