import sys

sys.path.append("../")
import unittest

from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Mscn.MscnPresetScheduler import get_mscn_preset_scheduler


class MscnTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000

    def test_mscn(self):
        try:
            scheduler = get_mscn_preset_scheduler(self.config, enable_collection=True, enable_training=True)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.execute(sql)
        finally:
            print("test_mscn ends")
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
