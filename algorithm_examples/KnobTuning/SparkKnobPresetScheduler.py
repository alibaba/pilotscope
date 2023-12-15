import sys

sys.path.append("../")
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.KnobTuning.EventImplement import KnobPeriodicModelUpdateEvent

from pilotscope.DBController.SparkSQLController import SparkSQLDataSourceEnum


def get_knob_spark_preset_scheduler(config: PilotConfig) -> PilotScheduler:

    config.set_spark_session_config({
        "spark.driver.memory": "20g",
        "spark.executor.memory": "20g",
        "spark.network.timeout": "1200s",
        "spark.executor.heartbeatInterval": "600s",
        "spark.sql.cbo.enabled": True,
        "spark.sql.cbo.joinReorder.enabled": True
    })

    # core
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
    scheduler.data_manager = DataManager(PostgreSQLConfig())  # hack
    scheduler.register_required_data("llamatune_data_spark", pull_execution_time=True)
    # allow to pretrain model
    periodic_db_controller_event = KnobPeriodicModelUpdateEvent(config, 2000,
                                                                llamatune_config_file="../algorithm_examples/KnobTuning/llamatune/configs/llama_config_spark.ini",
                                                                execute_on_init=True, optimizer_type="smac")
    scheduler.register_events([periodic_db_controller_event])

    # start
    scheduler.init()
    return scheduler
