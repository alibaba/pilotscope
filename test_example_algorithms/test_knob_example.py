import sys

sys.path.append("../")
import unittest
from pilotscope.Common.TimeStatistic import TimeStatistic
from algorithm_examples.ExampleConfig import get_time_statistic_img_path, example_pg_bin, example_pgdata
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PostgreSQLConfig
from algorithm_examples.utils import load_test_sql
from algorithm_examples.KnobTuning.KnobPresetScheduler import get_knob_preset_scheduler


class KnobTest(unittest.TestCase):
    def setUp(self):
        self.config: PostgreSQLConfig = PostgreSQLConfig()
        self.config.enable_deep_control_local(example_pg_bin, example_pgdata)
        self.config.db = "stats_tiny"
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000
        self.algo = "smac"

    def test_knob(self):
        try:
            scheduler = get_knob_preset_scheduler(self.config)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start('Knob')
                scheduler.execute(sql)
                TimeStatistic.end('Knob')
            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=False)
        except Exception as e:
            raise e
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
