import sys

sys.path.append("../")

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.TimeStatistic import TimeStatistic
from examples.ExampleConfig import get_time_statistic_img_path

import unittest
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig, SparkConfig
from pilotscope.PilotEnum import *
from pilotscope.PilotScheduler import PilotScheduler
from examples.utils import load_test_sql
from examples.ExampleConfig import get_time_statistic_xlsx_file_path


class MyTestCase(unittest.TestCase):
    def setUp(self):

        self.db = "stats_tiny"
        self.pg_test_data_table = "pg_default_time"
        self.spark_test_data_table = "spark_default_time"

    def test_0_pg_plan(self):
        config: PilotConfig = PostgreSQLConfig()
        config.db = self.db
        config.once_request_timeout = config.sql_execution_timeout = 120
        config.print()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)

        scheduler.register_collect_data(self.pg_test_data_table, pull_execution_time=True)

        # start
        scheduler.init()

        print("start to test sql")
        sqls = load_test_sql(config.db)
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            scheduler.simulate_db_console(sql)
        TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path("pg", config.db))
        name_2_value = TimeStatistic.get_average_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path("pg", self.db), is_rotation=True)
        TimeStatistic.clear()

    def test_1_spark_plan(self):
        config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        config.sql_execution_timeout = 120
        config.once_request_timeout = 120
        datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
        datasource_conn_info = {
            'host': 'localhost',
            'db': self.db,
            'user': 'postgres',
            'pwd': 'postgres'
        }
        config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        config.set_datasource(
            datasource_type,
            host=datasource_conn_info["host"],
            db=datasource_conn_info["db"],
            user=datasource_conn_info["user"],
            pwd=datasource_conn_info["pwd"]
        )
        config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.sql.cbo.enabled": True,
            "spark.sql.cbo.joinReorder.enabled": True,
            "spark.sql.pilotscope.enabled": True
        })

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        scheduler.pilot_data_manager = PilotTrainDataManager(PostgreSQLConfig())  # hack
        scheduler.register_collect_data(self.spark_test_data_table, pull_execution_time=True)

        scheduler.init()
        sqls = load_test_sql(config.db)
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            TimeStatistic.start(ExperimentTimeEnum.PIPE_END_TO_END)
            scheduler.simulate_db_console(sql)
            TimeStatistic.end(ExperimentTimeEnum.PIPE_END_TO_END)
            # TimeStatistic.print()
            print("{}-th sql OK".format(i), flush=True)
        TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path("spark", config.db))
        name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path("spark", self.db), is_rotation=True)

    def test_2_compare_performance(self):
        data_manager = PilotTrainDataManager(PostgreSQLConfig())
        pg_results = list(data_manager.read_all(self.pg_test_data_table)["execution_time"])
        algo_results = list(data_manager.read_all(self.spark_test_data_table)[
                                "execution_time"])  # Modify this to what you want to compare other
        Drawer.draw_bar(
            {"PostgreSQL": pg_results, "Spark": algo_results},
            file_name="defalut_draw_bar_file"
        )


if __name__ == '__main__':
    try:
        unittest.main()
    finally:
        pilotscope_exit()
