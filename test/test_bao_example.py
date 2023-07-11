import sys

from Dao.PilotTrainDataManager import PilotTrainDataManager
from common.Drawer import Drawer
from common.TimeStatistic import TimeStatistic
from common.dotDrawer import PlanDotDrawer
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path

sys.path.append("/PilotScopeCore/")
sys.path.append("/PilotScopeCore/components")
sys.path.append("/PilotScopeCore/examples/Bao/source")
sys.path.append("../")
sys.path.append("../components")
sys.path.append("../examples/Bao/source")

import unittest
from Factory.SchedulerFactory import SchedulerFactory
from common.Util import pilotscope_exit
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import *
from components.PilotScheduler import PilotScheduler
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler
from examples.Bao.BaoPilotModel import BaoPilotModel
from examples.Bao.EventImplement import BaoPretrainingModelEvent
from examples.utils import load_test_sql


class BaoTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)

        self.used_cache = False
        if self.used_cache:
            self.model_name = "bao_model_wc"
        else:
            self.model_name = "bao_model"

        self.test_data_table = "{}_{}_test_data_table".format(self.model_name, self.config.db)
        self.pg_test_data_table = "{}_{}_test_data_table".format("pg", self.config.db)
        self.pretraining_data_table = ("bao_pretraining_collect_data"
                                       if not self.used_cache
                                       else "bao_pretraining_collect_data_wc")
        self.algo = "bao"

    def test_bao(self):
        try:
            config = self.config

            bao_pilot_model: BaoPilotModel = BaoPilotModel(self.model_name, have_cache_data=self.used_cache)
            bao_pilot_model.load()
            bao_handler = BaoParadigmHintAnchorHandler(bao_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()
            if self.used_cache:
                state_manager.fetch_buffercache()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(bao_handler)
            scheduler.register_collect_data(training_data_save_table=self.test_data_table,
                                            state_manager=state_manager)

            #  updating model periodically
            # period_train_event = BaoPeriodTrainingEvent(training_data_save_table, config, 5, bao_pilot_model)
            # scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # allow to pretrain model

            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, self.pretraining_data_table,
                                                         enable_collection=False,
                                                         enable_training=False)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)
            # start
            scheduler.init()
            # exit()
            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start(ExperimentTimeEnum.END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            TimeStatistic.print()
            self.draw_time_statistic()
            print("run ok")
        finally:
            pilotscope_exit()

    def test_pg_plan(self):
        try:
            config = self.config

            state_manager = PilotStateManager(config)
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            scheduler.register_collect_data(self.pg_test_data_table, state_manager)

            # start
            scheduler.init()

            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()

    def test_draw_plan(self):
        train_data_manager = PilotTrainDataManager(self.config)
        df = train_data_manager.read_all(self.pretraining_data_table)
        res = PlanDotDrawer.get_plan_dot_str(df["plan"][2])
        pass

    def draw_time_statistic(self):
        name_2_value = TimeStatistic.get_average_data()
        # name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)

    def test_compare_performance(self):
        data_manager = PilotTrainDataManager(self.config)
        pg_results = list(data_manager.read_all(self.test_data_table)["execution_time"])[0:60]
        algo_results = list(data_manager.read_all(self.pg_test_data_table)["execution_time"])[0:60]
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Bao": algo_results},
            file_name="bao_performance"
        )


if __name__ == '__main__':
    unittest.main()
