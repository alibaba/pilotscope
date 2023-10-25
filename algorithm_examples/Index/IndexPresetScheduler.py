import sys

sys.path.append("../")
sys.path.append("../algorithm_examples/Index/index_selection_evaluation")
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import ExperimentTimeEnum, EventEnum
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Index.EventImplement import IndexPeriodicModelUpdateEvent


def get_index_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    test_data_table = "extend_{}_test_data_table".format(config.db)
    config.sql_execution_timeout = config.once_request_timeout = 50000
    config.print()

    # core
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)

    # allow to pretrain model
    periodic_model_update_event = IndexPeriodicModelUpdateEvent(config, 200, execute_on_init=True)
    scheduler.register_events([periodic_model_update_event])
    scheduler.register_required_data(test_data_table, pull_execution_time=True)

    # start
    TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
    scheduler.init()
    return scheduler
