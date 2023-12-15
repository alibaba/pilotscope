import os
import unittest

from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.DBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEvent import PeriodicModelUpdateEvent, QueryFinishEvent, WorkloadBeforeEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from pilotscope.PilotTransData import PilotTransData

query_finish_trigger_count = 0
workload_before_trigger_count = 0
model_update_trigger_count = 0


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
        global model_update_trigger_count
        model_update_trigger_count += 1


class ExampleQueryFinishEvent(QueryFinishEvent):

    def __init__(self, config, interval_count=1):
        super().__init__(config, interval_count)

    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        global query_finish_trigger_count
        query_finish_trigger_count += 1


class ExampleWorkloadBeforeEvent(WorkloadBeforeEvent):
    def __init__(self, config, enable=True):
        super().__init__(config, enable)

    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        global workload_before_trigger_count
        workload_before_trigger_count += 1


class TestScheduler(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.sqls = ["select date from badges where date=1406838696"] * 10
        cls.data_manager: DataManager = DataManager(cls.config)

    def test_scheduler(self):
        query_finish_interval = 2
        model_update_interval = 5
        config = self.config
        scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
        model = ExamplePilotModel("test_model")
        model.save_model()
        model = ExamplePilotModel("test_model")
        model.load_model()

        handler = ExampleCardPushHandler(model, config)
        scheduler.register_custom_handlers([handler])

        # regiser events
        model_update_event = ExamplePeriodicModelUpdateEvent(config, model_update_interval, execute_on_init=True)
        query_finish_event = ExampleQueryFinishEvent(config, query_finish_interval)
        workload_before_event = ExampleWorkloadBeforeEvent(config)
        scheduler.register_events([model_update_event, query_finish_event, workload_before_event])

        test_scheduler_table = "test_scheduler_table"
        scheduler.register_required_data(test_scheduler_table, pull_buffer_cache=True, pull_estimated_cost=True,
                                         pull_execution_time=True, pull_physical_plan=True, pull_subquery_2_cards=False)
        scheduler.init()

        self.data_manager.remove_table_and_tracker(test_scheduler_table)
        for sql in self.sqls:
            data = scheduler.execute(sql)
            print(data)

        self.assertEqual(len(self.data_manager.read_all(test_scheduler_table)), len(self.sqls))
        self.assertEqual(query_finish_trigger_count, len(self.sqls) // query_finish_interval)
        self.assertEqual(model_update_trigger_count, len(self.sqls) // model_update_interval + 1)
        self.assertEqual(workload_before_trigger_count, 1)

        self.data_manager.remove_table_and_tracker(test_scheduler_table)


if __name__ == '__main__':
    unittest.main()
