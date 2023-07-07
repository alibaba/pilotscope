import unittest

from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.TimeStatistic import TimeStatistic
from common.Util import pilotscope_exit
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from components.PilotScheduler import PilotScheduler
from examples.ExampleConfig import get_time_statistic_img_path
from examples.Index.EventImplement import IndexPeriodicDbControllerEvent
from examples.utils import load_sql


class IndexTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.algo = "index"

    def test_index(self):
        try:
            config = self.config

            state_manager = PilotStateManager(config)
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            # allow to pretrain model
            periodic_db_controller_event = IndexPeriodicDbControllerEvent(config, 200, exec_in_init=True)
            # scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
            scheduler.register_collect_data("extend_index_data", state_manager)

            # start
            scheduler.init()
            print("start to test sql")
            sqls = load_sql(config.test_sql_file)[0:10]
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start(ExperimentTimeEnum.END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.END_TO_END)
            self.draw_time_statistic()
        finally:
            pilotscope_exit()

    def draw_time_statistic(self):
        name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db),is_rotation=True)

    def test_default_index(self):
        try:
            config = self.config

            state_manager = PilotStateManager(config)
            state_manager.fetch_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            scheduler.register_collect_data("default_index_data", state_manager)

            # start
            scheduler.init()
            db_controller = DBControllerFactory.get_db_controller(config)
            db_controller.drop_all_indexes()
            print("start to test sql")
            sqls = load_sql(config.test_sql_file)[0:10]
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()

    def test_compare_performance(self):

        data_manager = PilotTrainDataManager(self.config)
        pg_results = list(data_manager.read_all("default_index_data")["execution_time"])
        extend_results = list(data_manager.read_all("extend_index_data")["execution_time"])
        drawer = Drawer()
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Extend": extend_results},
            file_name="extend_index_performance"
        )


if __name__ == '__main__':
    unittest.main()
