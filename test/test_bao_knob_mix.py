import sys
sys.path.append("../")
sys.path.append("../examples/Bao/source")

import time

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.common.Drawer import Drawer
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.dotDrawer import PlanDotDrawer
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
import unittest
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import *
from pilotscope.PilotScheduler import PilotScheduler
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler
from examples.Bao.BaoPilotModel import BaoPilotModel
from examples.Bao.EventImplement import BaoPretrainingModelEvent
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_test_sql


class BaoTest(unittest.TestCase):
    def setUp(self):
        self.config: PostgreSQLConfig = PostgreSQLConfig()
        # self.config.db = "imdbfull"
        self.config.db = "stats_tiny"

        self.config.set_db_type(DatabaseEnum.POSTGRESQL)

        self.used_cache = False
        if self.used_cache:
            self.model_name = "bao_model_wc"
        else:
            self.model_name = "bao_model"

        self.test_data_table = "{}_{}_test_data_table".format(self.model_name, self.config.db)
        self.pg_test_data_table = "{}_{}_test_data_table".format("pg", self.config.db)
        self.pretraining_data_table = ("bao_{}_pretraining_collect_data".format(self.config.db)
                                       if not self.used_cache
                                       else "bao_{}_pretraining_collect_data_wc".format(self.config.db))
        self.algo = "bao_knob"

    def test_bao_knob(self):
        try:
            config = self.config
            config.once_request_timeout = config.sql_execution_timeout = 20000
            config.print()

            bao_pilot_model: BaoPilotModel = BaoPilotModel(self.model_name, have_cache_data=self.used_cache)
            bao_pilot_model.load()
            bao_handler = BaoParadigmHintAnchorHandler(bao_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotDataInteractor(config)
            state_manager.pull_physical_plan()
            state_manager.pull_execution_time()
            if self.used_cache:
                state_manager.pull_buffercache()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(bao_handler)
            scheduler.register_collect_data(training_data_save_table=self.test_data_table,
                                            state_manager=state_manager)

            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, self.pretraining_data_table,
                                                         enable_collection=True,
                                                         enable_training=True)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)
            periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 200, llamatune_config_file = "../examples/KnobTuning/llamatune/configs/llama_config.ini", exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
            scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
            # start
            scheduler.init()
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo+"1", config.db))
            print("start to test sql")
            sqls = load_test_sql(config.db)
            print(sqls)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, total is {}".format(i, len(sqls)))
                TimeStatistic.start(ExperimentTimeEnum.SQL_END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.SQL_END_TO_END)
                TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo+"2", config.db))
            self.draw_time_statistic()
            print("run ok !!")
        finally:
            pilotscope_exit()

    def test_pg_plan(self):
        try:
            config = self.config
            config.once_request_timeout = config.sql_execution_timeout = 50000
            config.print()
            state_manager = PilotDataInteractor(config)
            state_manager.pull_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            scheduler.register_collect_data(self.pg_test_data_table, state_manager)

            # start
            scheduler.init()

            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql),flush=True)
                TimeStatistic.start(ExperimentTimeEnum.SQL_END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.SQL_END_TO_END)
                TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo+"2", config.db))
            self.draw_time_statistic()
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
        pg_results = list(data_manager.read_all(self.pg_test_data_table)["execution_time"])
        algo_results = list(data_manager.read_all(self.test_data_table)["execution_time"])
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Bao": algo_results},
            file_name="bao_performance"
        )


if __name__ == '__main__':
    unittest.main()
