import sys
sys.path.append("../")
sys.path.append("../examples/Lero/source")
import unittest
from pilotscope.common.TimeStatistic import TimeStatistic
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Drawer import Drawer
from pilotscope.common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from pilotscope.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_test_sql


class KnobTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000
        self.algo = "smac"

    def test_knob(self):
        config = self.config

        data_interactor = PilotDataInteractor(config)
        data_interactor.pull_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        # allow to pretrain model
        periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 200, llamatune_config_file = "../examples/KnobTuning/llamatune/configs/llama_config.ini", exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
        scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
        scheduler.register_collect_data("llamatune_data", data_interactor)
        TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
        # TimeStatistic.print()
        # start
        scheduler.init()
        print("start to test sql")
        sqls = load_test_sql(config.db)
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
            scheduler.simulate_db_console(sql)
            TimeStatistic.end(ExperimentTimeEnum.PIPE_END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            # TimeStatistic.print()
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
