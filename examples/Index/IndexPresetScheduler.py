import sys

sys.path.append("../")
sys.path.append("../examples/Index/index_selection_evaluation")
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import ExperimentTimeEnum, EventEnum, AllowedPullDataEnum
from pilotscope.PilotScheduler import PilotScheduler
from examples.Index.EventImplement import IndexPeriodicDbControllerEvent


def get_index_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    test_data_table = "extend_{}_test_data_table".format(config.db)
    config.sql_execution_timeout = config.once_request_timeout = 50000
    config.print()

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

    # allow to pretrain model
    periodic_db_controller_event = IndexPeriodicDbControllerEvent(config, 200, exec_in_init=True)
    scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
    scheduler.register_collect_data(test_data_table, pull_execution_time=True)

    # start
    TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
    scheduler.init()
    return scheduler
