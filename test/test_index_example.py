import unittest

from Factory.SchedulerFactory import SchedulerFactory
from common.Util import pilotscope_exit
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from components.PilotModel import PilotModel
from components.PilotScheduler import PilotScheduler
from examples.Lero.EventImplement import LeroPeriodTrainingEvent, \
    LeroPretrainingModelEvent
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_sql


class IndexTest(unittest.TestCase):
    def test_index(self):
        try:
            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)


            # allow to pretrain model
            pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, enable_collection=False,
                                                          enable_training=True)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

            # start
            scheduler.start()
            print("start to test sql")
            sqls = self.load_test_sqls()
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        finally:
            pilotscope_exit()

    def load_training_sqls(self):
        return load_sql("../examples/stats_train.txt")

    def load_test_sqls(self):
        return load_sql("../examples/stats_test.txt")


if __name__ == '__main__':
    unittest.main()
