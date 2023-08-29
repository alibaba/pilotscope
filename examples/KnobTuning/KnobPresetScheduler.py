import sys
sys.path.append("../")
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from pilotscope.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent

from pilotscope.DBController.SparkSQLController import SparkSQLController, SparkConfig, SUCCESS, FAILURE, SparkSQLDataSourceEnum

def get_knob_preset_scheduler(config: PilotConfig) -> PilotScheduler:
    
    # config.db = "stats_tiny"
    config.sql_execution_timeout = 300000
    config.once_request_timeout = 300000
    data_interactor = PilotDataInteractor(config)
    data_interactor.pull_execution_time()

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

    # allow to pretrain model
    periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 200, llamatune_config_file = "../examples/KnobTuning/llamatune/configs/llama_config.ini", exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
    scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)
    scheduler.register_collect_data("llamatune_data", data_interactor)
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
        host = datasource_conn_info["host"], 
        db = datasource_conn_info["db"], 
        user = datasource_conn_info["user"], 
        pwd = datasource_conn_info["pwd"]    
    )
    config.set_spark_session_config({
        "spark.sql.pilotscope.enabled": True,
        "spark.driver.memory": "20g",
        "spark.executor.memory":"20g",
        "spark.network.timeout":"1200s",
        "spark.executor.heartbeatInterval":"600s",
        "spark.sql.cbo.enabled":True,
        "spark.sql.cbo.joinReorder.enabled":True
    })
    
    data_interactor = PilotDataInteractor(config)
    data_interactor.pull_execution_time()
    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
    scheduler.pilot_data_manager = PilotTrainDataManager(PostgreSQLConfig()) # hack 
    scheduler.register_collect_data("llamatune_data_spark", data_interactor)
    # allow to pretrain model
    periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 2000, llamatune_config_file = "../examples/KnobTuning/llamatune/configs/llama_config_spark.ini", exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
    scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)

    # start
    scheduler.init()
    return scheduler