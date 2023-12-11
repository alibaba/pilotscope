import sys

sys.path.append("../")
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.KnobTuning.EventImplement import KnobPeriodicModelUpdateEvent


def get_knob_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    # config.db = "stats_tiny"
    config.sql_execution_timeout = 300000
    config.once_request_timeout = 300000

    # core
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
    scheduler.db_controller.backup_config()

    # allow to pretrain model
    periodic_model_update_event = KnobPeriodicModelUpdateEvent(config, 200,
                                                               execute_on_init=True,
                                                               llamatune_config_file="../algorithm_examples/KnobTuning/llamatune/configs/llama_config.ini",
                                                               optimizer_type="smac")
    scheduler.register_events([periodic_model_update_event])
    scheduler.register_required_data("llamatune_data", pull_execution_time=True)
    # TimeStatistic.print()
    # start
    scheduler.init()
    return scheduler
