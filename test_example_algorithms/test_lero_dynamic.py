import sys
sys.path.append("../")
sys.path.append("../algorithm_examples/Lero/source")
import unittest

from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.Drawer import Drawer
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Lero.EventImplement import LeroPeriodicModelUpdateEvent, \
    LeroPeriodicCollectEvent
from algorithm_examples.Lero.LeroParadigmCardAnchorHandler import LeroCardPushHandler
from algorithm_examples.Lero.LeroPilotModel import LeroPilotModel
from algorithm_examples.utils import load_test_sql
from algorithm_examples.Lero.LeroPresetScheduler import get_lero_dynamic_preset_scheduler

class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.model_name = "lero_pair"

    def test_lero_dynamic(self):
        try:
            scheduler = get_lero_dynamic_preset_scheduler(self.config)
            # exit()
            print("start to dynamic train and test sql")
            sqls = load_test_sql(self.config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        except Exception as e:
            pilotscope_exit(e)


if __name__ == '__main__':
    unittest.main()
