import sys
sys.path.append("..")
sys.path.append("../components")

import unittest
from common.TimeStatistic import TimeStatistic
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.Util import pilotscope_exit
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from components.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_sql
import unittest
import json

from DBController.SparkSQLController import SparkSQLController, SparkConfig, SUCCESS, FAILURE, SparkSQLDataSourceEnum
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from common.Index import Index
from pyspark.sql import SparkSession
import sqlglot

import unittest
from common.TimeStatistic import TimeStatistic
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from Factory.SchedulerFactory import SchedulerFactory
from common.Drawer import Drawer
from common.Util import pilotscope_exit
from components.PilotConfig import PilotConfig, SparkConfig, PostgreSQLConfig
from components.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from components.PilotScheduler import PilotScheduler
from examples.KnobTuning.EventImplement import KnobPeriodicDbControllerEvent
from examples.utils import load_sql, load_test_sql


class KnobTest(unittest.TestCase):
    def setUp(self):
        self.algo = "smac"
        self.config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        # self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.sql_execution_timeout = 120
        self.config.once_request_timeout = 120
        datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
        datasource_conn_info = {
            'host': 'localhost',
            'db': 'tpcds',
            'user': 'postgres',
            'pwd': 'postgres'
        }
        self.config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        self.config.set_datasource(
            datasource_type, 
            host = datasource_conn_info["host"], 
            db = datasource_conn_info["db"], 
            user = datasource_conn_info["user"], 
            pwd = datasource_conn_info["pwd"]    
        )
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.driver.memory": "20g",
            "spark.executor.memory":"20g",
            "spark.network.timeout":"1200s",
            "spark.executor.heartbeatInterval":"600s",
            "spark.sql.cbo.enabled":True,
            "spark.sql.cbo.joinReorder.enabled":True,
            "spark.sql.pilotscope.enabled": True
        })
        
    
    def test_knob(self):
        config = self.config

        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()
        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        scheduler.pilot_data_manager = PilotTrainDataManager(PostgreSQLConfig()) # hack 
        scheduler.register_collect_data("llamatune_data_spark4", state_manager)

        # allow to pretrain model
        periodic_db_controller_event = KnobPeriodicDbControllerEvent(config, 2000, llamatune_config_file = "../examples/KnobTuning/llamatune/configs/llama_config_spark.ini", exec_in_init = True, optimizer_type = "smac") # optimizer_type could be "smac" or "ddpg"
        scheduler.register_event(EventEnum.PERIODIC_DB_CONTROLLER_EVENT, periodic_db_controller_event)

        # start
        scheduler.init()
        sqls = load_sql("../examples/tpcds_test_sql_full.txt")
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
    
    def test_default_knob(self):

        config = self.config
        self.algo = "spark"
        state_manager = PilotStateManager(config)
        state_manager.fetch_execution_time()
        # state_manager.fetch_subquery_card()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        scheduler.pilot_data_manager = PilotTrainDataManager(PostgreSQLConfig()) # hack 
        scheduler.register_collect_data("default_knob_data_spark_4", state_manager)
        
        scheduler.init()
        sqls = load_sql("../examples/tpcds_test_sql_full.txt")
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
