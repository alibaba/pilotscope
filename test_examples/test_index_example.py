import unittest
import sys
sys.path.append("../")
sys.path.append("../examples/Index/index_selection_evaluation")
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Drawer import Drawer
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, ExperimentTimeEnum, EventEnum
from pilotscope.PilotScheduler import PilotScheduler
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from examples.Index.EventImplement import IndexPeriodicDbControllerEvent
from examples.utils import load_test_sql


class IndexTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        # self.config.db = "imdb"
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.algo = "extend"

        self.test_data_table = "{}_{}_test_data_table2".format(self.algo, self.config.db)
        self.pg_test_data_table = "{}_{}_test_data_table2".format("pg", self.config.db)

    def test_index(self):
        try:
            config = self.config
            config.sql_execution_timeout = config.once_request_timeout = 50000
            config.print()

            data_interactor = PilotDataInteractor(config)
            data_interactor.pull_execution_time()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

            # allow to pretrain model
            periodic_db_controller_event = IndexPeriodicDbControllerEvent(config, 200, exec_in_init=True)
            scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
            scheduler.register_collect_data(self.test_data_table, data_interactor)

            # start
            TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
            scheduler.init()
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            # sqls = []
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start(ExperimentTimeEnum.SQL_END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.SQL_END_TO_END)
                TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            TimeStatistic.end(ExperimentTimeEnum.PIPE_END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))

            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
