import sys
import unittest

sys.path.append("../")
sys.path.append("../algorithm_examples/Index/index_selection_evaluation")
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from algorithm_examples.ExampleConfig import get_time_statistic_img_path
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Index.IndexPresetScheduler import get_index_preset_scheduler


class IndexTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.algo = "extend"

    def test_index(self):
        try:
            scheduler = get_index_preset_scheduler(self.config)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            # sqls = []
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start('Index')
                scheduler.execute(sql)
                TimeStatistic.end('Index')
            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=False)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
