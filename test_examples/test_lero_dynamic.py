import sys
sys.path.append("../")
sys.path.append("../examples/Lero/source")
import unittest

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Drawer import Drawer
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from examples.Lero.EventImplement import LeroPeriodTrainingEvent, \
    LeroDynamicCollectEventPeriod
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_test_sql


class LeroTest(unittest.TestCase):
    def setUp(self):
        self.config: PilotConfig = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.model_name = "lero_pair"
        self.test_data_table = "{}_test_data_table".format(self.model_name)
        self.pg_test_data_table = "pg_test_data_table"
        self.pretraining_data_table = "lero_pretraining_collect_data"

    def test_lero_dynamic(self):
        try:

            import torch
            print(torch.version.cuda)
            if torch.cuda.is_available():
                print("Using GPU")
            else:
                print("Using CPU")

            config = self.config
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            model_name = "lero_pair" # This test can only work when existing a model
            lero_pilot_model: PilotModel = LeroPilotModel(model_name)
            lero_pilot_model.load()
            lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

            # Register what data needs to be cached for training purposes
            state_manager = PilotDataInteractor(config)
            state_manager.pull_physical_plan()
            state_manager.pull_execution_time()

            # core
            training_data_save_table = "{}_data_table".format(model_name)
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(lero_handler)
            scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                            state_manager=state_manager)

            # dynamically collect data
            dynamic_training_data_save_table = "{}_period_training_data_table".format(model_name)
            period_collect_event = LeroDynamicCollectEventPeriod(dynamic_training_data_save_table, config, 100)
            scheduler.register_event(EventEnum.PERIODIC_COLLECTION_EVENT, period_collect_event)

            # dynamically update model
            period_train_event = LeroPeriodTrainingEvent(dynamic_training_data_save_table, config, 100,
                                                         lero_pilot_model)
            scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # start
            scheduler.init()

            # exit()
            print("start to dynamic train and test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        except Exception as e:
            pilotscope_exit(e)


if __name__ == '__main__':
    unittest.main()
