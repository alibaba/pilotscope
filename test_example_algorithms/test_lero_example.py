import sys

sys.path.append("../")
sys.path.append("../algorithm_examples/Lero/source")
import unittest

from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Lero.LeroPresetScheduler import get_lero_preset_scheduler


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"

    def test_lero(self):
        try:
            config = self.config
            # model_name = "leroDynamic"

            scheduler = get_lero_preset_scheduler(config, True, True)

            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
