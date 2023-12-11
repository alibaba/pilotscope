import sys

sys.path.append("../")
sys.path.append("../algorithm_examples/Lero/source")
import unittest

from pilotscope.Common.Util import pilotscope_exit
from pilotscope.Common.Drawer import Drawer
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.Common.TimeStatistic import TimeStatistic
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Lero.LeroPresetScheduler import get_lero_preset_scheduler
from algorithm_examples.ExampleConfig import get_time_statistic_img_path


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.algo = "lero"

    def test_lero(self):
        try:
            config = self.config
            scheduler = get_lero_preset_scheduler(config, enable_collection=True, enable_training=True)
            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start('Lero')
                scheduler.execute(sql)
                TimeStatistic.end('Lero')
            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=False)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
