import sys
import unittest

sys.path.append("../")
sys.path.append("../algorithm_examples/Index/index_selection_evaluation")
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, ExperimentTimeEnum
from algorithm_examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Index.IndexPresetScheduler import get_index_preset_scheduler


class IndexTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.algo = "extend"

    def test_index(self):
        try:
            scheduler = get_index_preset_scheduler(self.config)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            # sqls = []
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                TimeStatistic.start(ExperimentTimeEnum.SQL_END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.SQL_END_TO_END)
                TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, self.config.db))
            TimeStatistic.end(ExperimentTimeEnum.PIPE_END_TO_END)
            TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, self.config.db))

            name_2_value = TimeStatistic.get_sum_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
