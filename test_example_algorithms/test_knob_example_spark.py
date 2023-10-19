import sys
sys.path.append("../")
import unittest
from pilotscope.Common.TimeStatistic import TimeStatistic
from algorithm_examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotEnum import DatabaseEnum, EventEnum, ExperimentTimeEnum
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.utils import load_sql
import unittest

from pilotscope.DBController.SparkSQLController import SparkSQLController, SparkConfig, SUCCESS, FAILURE, SparkSQLDataSourceEnum
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig

from pilotscope.PilotConfig import PilotConfig, SparkConfig, PostgreSQLConfig
from algorithm_examples.utils import load_sql, load_test_sql

from algorithm_examples.KnobTuning.KnobPresetScheduler import get_knob_spark_preset_scheduler

class KnobTest(unittest.TestCase):
    def setUp(self):
        self.algo = "smac"
        self.config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        # self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.sql_execution_timeout = 120
        self.config.once_request_timeout = 120
        self.config.set_db("stats_tiny")
    
    def test_knob(self):
        config = self.config

        scheduler = get_knob_spark_preset_scheduler(self.config)
        
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
