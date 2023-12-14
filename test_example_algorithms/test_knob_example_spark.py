import sys

from algorithm_examples.KnobTuning.SparkKnobPresetScheduler import get_knob_spark_preset_scheduler

sys.path.append("../")
from pilotscope.Common.TimeStatistic import TimeStatistic
from algorithm_examples.ExampleConfig import get_time_statistic_img_path
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.Util import pilotscope_exit
import unittest

from pilotscope.PilotConfig import PilotConfig, SparkConfig
from algorithm_examples.utils import load_test_sql



class KnobTest(unittest.TestCase):
    def setUp(self):
        self.algo = "smac"
        self.config: PilotConfig = SparkConfig(app_name="testApp", master_url="local[*]")
        # self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.config.sql_execution_timeout = 120
        self.config.once_request_timeout = 120
        self.config.db = "stats_tiny"

    def test_knob(self):
        config = self.config

        scheduler = get_knob_spark_preset_scheduler(self.config)

        sqls = load_test_sql(config.db)
        for i, sql in enumerate(sqls):
            print("current is the {}-th sql, and it is {}".format(i, sql))
            TimeStatistic.start("Knob")
            scheduler.execute(sql)
            TimeStatistic.end("Knob")
        name_2_value = TimeStatistic.get_sum_data()
        Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)


if __name__ == '__main__':
    try:
        unittest.main()
    except Exception as e:
        raise e
    finally:
        pilotscope_exit()
