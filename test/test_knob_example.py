import sys
sys.path.append("..")
sys.path.append("../components")

import unittest
from common.TimeStatistic import TimeStatistic
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.Util import pilotscope_exit
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from components.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_sql


class KnobTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000
        self.algo = "smac"

    def test_knob(self):
        config = self.config

        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        # allow to pretrain model
        periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 200, exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
        scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
        scheduler.register_collect_data("llamatune_data", state_manager)
        TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
        TimeStatistic.print()
        # start
        scheduler.init()
        print("start to test sql")
        sqls = load_sql("../examples/stats_test.txt")
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            TimeStatistic.start(ExperimentTimeEnum.END_TO_END)
            scheduler.simulate_db_console(sql)
            TimeStatistic.end(ExperimentTimeEnum.END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            TimeStatistic.print()
            print("{}-th sql OK".format(i),flush = True)
        name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)
        
    def test_default_knob(self):
        config = self.config
        self.algo = "pg"
        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        scheduler.register_collect_data("default_knob_data_stats", state_manager)

        # start
        # db_controller = state_manager.db_controller
        # db_controller.recover_config()
        # db_controller.restart()
        
        scheduler.init()
        print("start to test sql")
        sqls = load_sql("../examples/stats_test.txt")
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            TimeStatistic.start(ExperimentTimeEnum.END_TO_END)
            scheduler.simulate_db_console(sql)
            TimeStatistic.end(ExperimentTimeEnum.END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            TimeStatistic.print()
            print("{}-th sql OK".format(i),flush = True)
        name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)


if __name__ == '__main__':
    try:
        unittest.main()
    except Exception as e:
        raise e
    finally:
        pilotscope_exit()
