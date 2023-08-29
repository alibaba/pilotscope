import sys
sys.path.append("../")
sys.path.append("../examples/Index/index_selection_evaluation")
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, ExperimentTimeEnum, EventEnum
from pilotscope.PilotScheduler import PilotScheduler
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from examples.Index.EventImplement import IndexPeriodicDbControllerEvent
from examples.utils import load_test_sql


def get_index_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    
    test_data_table = "extend_{}_test_data_table".format(config.db)
    config.sql_execution_timeout = config.once_request_timeout = 50000
    config.print()

    data_interactor = PilotDataInteractor(config)
    data_interactor.pull_execution_time()

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

    # allow to pretrain model
    periodic_db_controller_event = IndexPeriodicDbControllerEvent(config, 200, exec_in_init=True)
    scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
    scheduler.register_collect_data(test_data_table, data_interactor)

    # start
    TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
    scheduler.init()
    return scheduler