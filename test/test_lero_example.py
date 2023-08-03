import sys
sys.path.append("../")
sys.path.append("../examples/Lero/source")
import unittest

from pilotscope.Dao.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Drawer import Drawer
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DataFetcher.PilotStateManager import PilotStateManager
from pilotscope.PilotConfig import PilotConfig,PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from examples.ExampleConfig import pg_stats_test_result_table
from examples.Lero.EventImplement import LeroPretrainingModelEvent
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_test_sql


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.model_name = "lero_pair"
        self.test_data_table = "{}_test_data_table".format(self.model_name)
        self.pretraining_data_table = "lero_pretraining_collect_data"

    def test_0_lero(self):
        try:
            config = self.config
            # model_name = "leroDynamic"
            lero_pilot_model: PilotModel = LeroPilotModel(self.model_name)
            lero_pilot_model.load()
            lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(lero_handler)
            scheduler.register_collect_data(training_data_save_table=self.test_data_table,
                                            state_manager=state_manager)

            # allow to pretrain model
            pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, self.pretraining_data_table,
                                                          enable_collection=True, enable_training=True)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

            # start
            scheduler.init()
            
            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()

    def test_pg_plan(self):
        try:
            config = self.config

            state_manager = PilotStateManager(config)
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            scheduler.register_collect_data(pg_stats_test_result_table, state_manager)

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
        pg_results = list(data_manager.read_all(self.test_data_table)["execution_time"])
        algo_results = list(data_manager.read_all(pg_stats_test_result_table)["execution_time"])
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Lero": algo_results},
            file_name="lero_performance"
        )



if __name__ == '__main__':
    unittest.main()
