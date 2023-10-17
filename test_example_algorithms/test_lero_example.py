import sys
sys.path.append("../")
sys.path.append("../examples/Lero/source")
import unittest

from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PilotConfig,PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum
from examples.utils import load_test_sql
from examples.Lero.LeroPresetScheduler import get_lero_preset_scheduler

class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        

    def test_0_lero(self):
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
