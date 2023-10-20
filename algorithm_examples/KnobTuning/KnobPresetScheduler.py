import sys

sys.path.append("../")
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import EventEnum, AllowedPullDataEnum
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.KnobTuning.EventImplement import KnobPeriodicModelUpdateEvent

from pilotscope.DBController.SparkSQLController import SparkSQLDataSourceEnum


def get_knob_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    # config.db = "stats_tiny"
    config.sql_execution_timeout = 300000
    config.once_request_timeout = 300000

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

    # allow to pretrain model
    periodic_db_controller_event = KnobPeriodicModelUpdateEvent(config, 200,
                                                                llamatune_config_file="../algorithm_examples/KnobTuning/llamatune/configs/llama_config.ini",
                                                                execute_before_first_query=True, optimizer_type="smac")
    scheduler.register_events([periodic_db_controller_event])
    scheduler.register_required_data("llamatune_data", pull_execution_time=True)
    # TimeStatistic.print()
    # start
    scheduler.init()
    return scheduler


def get_knob_spark_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
    datasource_conn_info = {
        'host': 'localhost',
        'db': config.db,
        'user': 'postgres',
        'pwd': 'postgres'
    }
    config.set_datasource(
        datasource_type,
        host=datasource_conn_info["host"],
        db=datasource_conn_info["db"],
        user=datasource_conn_info["user"],
        pwd=datasource_conn_info["pwd"]
    )
    config.set_spark_session_config({
        "spark.sql.pilotscope.enabled": True,
        "spark.driver.memory": "20g",
        "spark.executor.memory": "20g",
        "spark.network.timeout": "1200s",
        "spark.executor.heartbeatInterval": "600s",
        "spark.sql.cbo.enabled": True,
        "spark.sql.cbo.joinReorder.enabled": True
    })

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
    scheduler.data_manager = DataManager(PostgreSQLConfig())  # hack
    scheduler.register_required_data("llamatune_data_spark", pull_execution_time=True)
    # allow to pretrain model
    periodic_db_controller_event = KnobPeriodicModelUpdateEvent(config, 2000,
                                                                llamatune_config_file="../algorithm_examples/KnobTuning/llamatune/configs/llama_config_spark.ini",
                                                                execute_before_first_query=True, optimizer_type="smac")
    scheduler.register_events([periodic_db_controller_event])

    # start
    scheduler.init()
    return scheduler
