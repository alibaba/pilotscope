import sys
sys.path.append("../")
import unittest

from pilotscope.common.Drawer import Drawer
from pilotscope.common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig

from examples.utils import load_sql,load_test_sql
from examples.Mscn.MscnPresetScheduler import get_mscn_preset_scheduler

class MscnTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.sql_execution_timeout = 300000
        self.config.once_request_timeout = 300000

    def test_mscn(self):
        try:
            scheduler = get_mscn_preset_scheduler(self.config, True, True)
            print("start to test sql")
            sqls = load_test_sql(self.config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            print("test_mscn ends")
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
