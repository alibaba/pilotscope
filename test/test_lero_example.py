import unittest

from Anchor.BaseAnchor.FetchAnchorHandler import RecordFetchAnchorHandler
from Factory.SchedulerFactory import SchedulerFactory
from common.Util import pilotscope_exit
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from components.PilotModel import PilotModel
from components.PilotScheduler import PilotScheduler
from examples.Lero.EventImplement import LeroPeriodTrainingEvent, \
    LeroPretrainingModelEvent, LeroDynamicCollectEventPeriod
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel
from examples.utils import load_sql


class LeroTest(unittest.TestCase):
    def test_lero(self):
        try:
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
            pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, enable_collection=True,
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

    def test_lero_dynamic(self):
        try:

            import torch
            print(torch.version.cuda)
            if torch.cuda.is_available():
                print("Using GPU")
            else:
                print("Using CPU")

            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            model_name = "leroDynamic"
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

            # dynamically collect data
            dynamic_training_data_save_table = "{}_period_training_data_table".format(model_name)
            period_collect_event = LeroDynamicCollectEventPeriod(dynamic_training_data_save_table, config, 100)
            scheduler.register_event(EventEnum.PERIODIC_COLLECTION_EVENT, period_collect_event)

            # dynamically update model
            period_train_event = LeroPeriodTrainingEvent(dynamic_training_data_save_table, config, 100,
                                                         lero_pilot_model)
            scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

            # start
            scheduler.start()

            # exit()
            print("start to dynamic train and test sql")
            sqls = self.load_training_sqls()
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                scheduler.simulate_db_console(sql)
        except Exception as e:
            pilotscope_exit(e)

    def test_pg_plan(self):
        try:
            config: PilotConfig = PilotConfig()
            config.db = "stats"
            config.set_db_type(DatabaseEnum.POSTGRESQL)

            # Register what data needs to be cached for training purposes
            state_manager = PilotStateManager(config)
            state_manager.fetch_physical_plan()
            state_manager.fetch_execution_time()

            # core
            training_data_save_table = "{}_data_table".format("pg_plan")
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                            state_manager=state_manager)

            print("start to get pg_plan")
            sqls = self.load_training_sqls()
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, and it is {}".format(i, sql))
                state_manager = PilotStateManager(scheduler.config)

                state_manager.add_anchors(scheduler.collect_data_state_manager.anchor_to_handlers.values())

                result = state_manager.execute(sql, enable_clear=False)
                if result is not None:
                    scheduler._post_process(result)
                    return result.records

        finally:
            pilotscope_exit()

    def load_training_sqls(self):
        return load_sql("../examples/stats_train.txt")

    def load_test_sqls(self):
        return load_sql("../examples/stats_test.txt")


if __name__ == '__main__':
    unittest.main()
