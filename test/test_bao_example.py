import sys
sys.path.append("../")
sys.path.append("../components")
sys.path.append("../examples/Bao/source")
import unittest

from Factory.SchedulerFactory import SchedulerFactory
from common.Util import pilotscope_exit
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from components.PilotModel import PilotModel
from components.PilotScheduler import PilotScheduler
# from examples.Lero.EventImplement import LeroPeriodTrainingEvent, \
#     LeroPretrainingModelEvent
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler
from examples.Bao.BaoPilotModel import BaoPilotModel
from examples.Bao.EventImplement import BaoPretrainingModelEvent, BaoPeriodTrainingEvent
from examples.utils import load_sql
import json

class BaoTest(unittest.TestCase):
    def test_bao(self):
        try:
            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            used_cache = True
            if used_cache:
                model_name = "bao_model_wc"
            else:
                model_name = "bao_model"
            bao_pilot_model: PilotModel = BaoPilotModel(model_name, have_cache_data = used_cache)
            bao_pilot_model.load()
            bao_handler = BaoParadigmHintAnchorHandler(bao_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()
            if used_cache:
                state_manager.fetch_buffercache()

            # core
            training_data_save_table = "{}_data_table".format(model_name)
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(bao_handler)
            scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                            state_manager=state_manager)

            #  updating model periodically
            period_train_event = BaoPeriodTrainingEvent(training_data_save_table, config, 5, bao_pilot_model)
            scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # allow to pretrain model
            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, enable_collection=True,
                                                          enable_training=True)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)
            
            # start
            scheduler.start()

            print("start to test sql")
            sqls = self.load_test_sqls()
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
                # exit()
        finally:
            pilotscope_exit()

    def load_training_sqls(self):
        return load_sql("../examples/stats_train_10_sql.txt")

    def load_test_sqls(self):
        return load_sql("../examples/stats_test_10_sql.txt")


if __name__ == '__main__':
    unittest.main()
