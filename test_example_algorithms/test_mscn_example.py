import sys

sys.path.append("../")

import unittest

from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Mscn.MscnPresetScheduler import get_mscn_preset_scheduler
from algorithm_examples.ExampleConfig import get_time_statistic_img_path
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.TimeStatistic import TimeStatistic


class MscnTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000
        self.algo = "mscn"

    def test_mscn(self):
        try:
            scheduler = get_mscn_preset_scheduler(self.config, enable_collection=True, enable_training=True)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            for i, sql in enumerate(sqls):
                if i % 10 == 0:
                    print("current is the {}-th sql, and total is {}".format(i, len(sqls)))
                TimeStatistic.start('Mscn')
                scheduler.execute(sql)
                TimeStatistic.end('Mscn')
            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=False)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
