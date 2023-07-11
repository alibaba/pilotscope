import unittest

from Dao.PilotTrainDataManager import PilotTrainDataManager
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.Util import pilotscope_exit
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from components.PilotModel import PilotModel
from components.PilotScheduler import PilotScheduler
from examples.Lero.EventImplement import LeroPeriodTrainingEvent, \
    LeroDynamicCollectEventPeriod
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_test_sql


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.model_name = "lero_pair"
        self.test_data_table = "{}_test_data_table".format(self.model_name)
        self.pg_test_data_table = "pg_test_data_table"
        self.pretraining_data_table = "lero_pretraining_collect_data"

    def test_lero_dynamic(self):
        try:

            import torch
            print(torch.version.cuda)
            if torch.cuda.is_available():
                print("Using GPU")
            else:
                print("Using CPU")

            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            model_name = "leroDynamic"
            lero_pilot_model: PilotModel = LeroPilotModel(model_name)
            lero_pilot_model.load()
            lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()

            # core
            training_data_save_table = "{}_data_table".format(model_name)
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(lero_handler)
            scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                            state_manager=state_manager)

            # dynamically collect data
            dynamic_training_data_save_table = "{}_period_training_data_table".format(model_name)
            period_collect_event = LeroDynamicCollectEventPeriod(dynamic_training_data_save_table, config, 100)
            scheduler.register_event(EventEnum.PERIODIC_COLLECTION_EVENT, period_collect_event)

            # dynamically update model
            period_train_event = LeroPeriodTrainingEvent(dynamic_training_data_save_table, config, 100,
                                                         lero_pilot_model)
            scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # start
            scheduler.start()

            # exit()
            print("start to dynamic train and test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        except Exception as e:
            pilotscope_exit(e)

    def test_pg_plan(self):
        try:
            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_collect_data(training_data_save_table=self.pg_test_data_table,
                                            state_manager=state_manager)

            print("start to get pg_plan")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                state_manager = PilotStateManager(scheduler.config)

                state_manager.add_anchors(scheduler.collect_data_state_manager.anchor_to_handlers.values())

                result = state_manager.execute(sql, is_reset=False)
                if result is not None:
                    scheduler._post_process(result)
                    return result.records

        finally:
            pilotscope_exit()

    def test_default_index(self):
        try:
            config = self.config

            state_manager = PilotStateManager(config)
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            scheduler.register_collect_data("default_lero_static_data", state_manager)

            # start
            scheduler.init()

            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()

    def test_compare_performance(self):

        data_manager = PilotTrainDataManager(self.config)
        pg_results = list(data_manager.read_all("default_lero_static_data")["execution_time"])
        algo_results = list(data_manager.read_all("lero_pair_data_table")["execution_time"])
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Lero": algo_results},
            file_name="lero_performance"
        )


if __name__ == '__main__':
    unittest.main()
