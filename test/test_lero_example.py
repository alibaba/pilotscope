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
    LeroPretrainingModelEvent
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_sql


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)

    def test_lero(self):
        try:
            config = self.config
            # model_name = "leroDynamic"
            model_name = "lero_pair"
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

            #  updating model periodically
            period_train_event = LeroPeriodTrainingEvent(training_data_save_table, config, 100, lero_pilot_model)
            scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # allow to pretrain model
            pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, enable_collection=False,
                                                          enable_training=False)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

            # start
            scheduler.init()
            print("start to test sql")
            sqls = self.load_test_sqls()[126:]
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
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
            sqls = load_sql(config.test_sql_file)
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


    def load_training_sqls(self):
        return load_sql("../examples/stats_train.txt")

    def load_test_sqls(self):
        return load_sql("../examples/stats_test.txt")


if __name__ == '__main__':
    unittest.main()
