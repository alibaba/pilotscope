import unittest

from Factory.SchedulerFactory import SchedulerFactory
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


class LeroTest(unittest.TestCase):
    def test_lero(self):
        config: PilotConfig = PilotConfig()
        config.db = "stats"
        config.set_db_type(DatabaseEnum.POSTGRESQL)

        # model_name = "leroDynamic"
        model_name = "leroPair"
        lero_pilot_model: PilotModel = LeroPilotModel(model_name)
        lero_pilot_model.load()
        lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

        # Register what data needs to be cached for training purposes
        state_manager = PilotStateManager(config)
        state_manager.fetch_physical_plan()
        state_manager.fetch_execution_time()

        # core
        training_data_save_table = "{}_data_table".format(model_name)
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        scheduler.register_anchor_handler(lero_handler)
        scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                        state_manager=state_manager)

        #  updating model periodically
        period_train_event = LeroPeriodTrainingEvent(training_data_save_table, config, 100, lero_pilot_model)
        scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

        # allow to pretrain model
        pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, enable_collection=False,
                                                      enable_training=False)
        scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

        # start
        scheduler.start()

        sqls = self.load_test_sqls()
        for sql in sqls:
            scheduler.simulate_db_console(sql)

    def load_training_sqls(self):
        return load_sql("../examples/stats_train_10_sql.txt")

    def load_test_sqls(self):
        return load_sql("../examples/stats_test_10_sql.txt")


if __name__ == '__main__':
    unittest.main()
