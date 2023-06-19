import unittest

from PilotEvent import PeriodTrainingEvent, PretrainingModelEvent
from examples.Lero.InterfaceImplement import LeroPretrainingEventInterface
from examples.Lero.LeroPilotModel import LeroPilotModel
from components.DataFetcher.PilotStateManager import PilotStateManager
from components.PilotConfig import PilotConfig
from components.PilotEnum import DatabaseEnum, EventEnum
from Factory.SchedulerFactory import SchedulerFactory
from components.PilotModel import PilotModel
from components.PilotScheduler import PilotScheduler
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler


class LeroTest(unittest.TestCase):
    def test_lero(self):
        config: PilotConfig = PilotConfig()
        config.db = "stats"

        config.set_db_type(DatabaseEnum.POSTGRESQL)

        lero_pilot_model: PilotModel = LeroPilotModel("leroPair")
        lero_pilot_model.load()
        lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

        # Register what data needs to be cached for training purposes
        state_manager = PilotStateManager(config)
        state_manager.fetch_physical_plan()
        state_manager.fetch_execution_time()

        # core
        scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
        scheduler.register_anchor_handler(lero_handler)
        scheduler.register_collect_data("lero", state_manager)

        #  updating model periodically
        period_train_event = PeriodTrainingEvent(config, 100, lero_pilot_model.update)
        scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

        # allow to pretrain model
        pretraining_event = PretrainingModelEvent(config, LeroPretrainingEventInterface(config, lero_pilot_model))
        scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

        # start
        scheduler.start()

        sql = "select * from badges limit 10;"
        scheduler.simulate_db_console_offline(sql)
        print("end")


if __name__ == '__main__':
    unittest.main()
