import sys

sys.path.append("..")
sys.path.append("../components")

import unittest

from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.Util import pilotscope_exit
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from components.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_sql


class KnobTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)

    def test_knob(self):
        config = self.config

        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        # allow to pretrain model
        periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 200, exec_in_init=True,
                                                                     optimizer_type="ddpg")  # optimizer_type could be "smac" or "ddpg"
        scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
        scheduler.register_collect_data("llamatune_data", state_manager)

        # start
        scheduler.init()
        print("start to test sql")
        sqls = load_sql("../examples/stats_light_test.sql")
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            scheduler.simulate_db_console(sql)

    def test_default_knob(self):
        config = self.config

        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        scheduler.register_collect_data("default_knob_data", state_manager)

        # start
        db_controller = state_manager.db_controller
        db_controller.recover_config()
        db_controller.restart()

        scheduler.init()
        print("start to test sql")
        sqls = load_sql("../examples/stats_light_test.sql")
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            scheduler.simulate_db_console(sql)

    def test_compare_performance(self):

        data_manager = PilotTrainDataManager(self.config)
        pg_results = list(data_manager.read_all("default_knob_data")[
                              "execution_time"])  # [0.7868, 0.5763, 0.3646, 0.5928, 0.5978, 0.7326, 0.626, 0.3306, 0.5859, 0.5794, 0.6649]
        llamatune_results = list(data_manager.read_all("llamatune_data")[
                                     "execution_time"])  # [0.7467, 0.5382, 0.3189, 0.577, 0.4795, 0.6371, 0.5719, 0.3398, 0.5898, 0.4836, 0.6703]
        print(pg_results, llamatune_results)
        # Drawer.draw_bar(
        #     {"PostgreSQL": pg_results, "llamatune": llamatune_results},
        #     file_name="llamatune_performance"
        # )


if __name__ == '__main__':
    try:
        unittest.main()
    finally:
        pilotscope_exit()
