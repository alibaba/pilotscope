import threading

from apscheduler.schedulers.background import BackgroundScheduler

from Dao.PilotTrainDataManager import PilotTrainDataManager
from Interface.PeriodCollectDataEventInterface import *
from Interface.PretrainingEventInterface import PretrainingEventInterface
from PilotConfig import PilotConfig


class Event(ABC):
    def __init__(self, config):
        self.config = config


class PeriodTrainingEvent(Event):
    def __init__(self, config, period, func):
        super().__init__(config)
        self.func = func
        self.period = period
        self.cur_count = 0

    # def __init__(self, config, period, func) -> None:
    #     super.__init__(config)
    #     self.func = func
    #     self.period = period
    #     self.cur_count = 0

    def update(self, pilot_data_manager: PilotTrainDataManager):
        self.cur_count += 1
        if self.cur_count >= self.period:
            self.cur_count = 0
            self.trigger(pilot_data_manager)

    def trigger(self, pilot_data_manager: PilotTrainDataManager):
        self.func(pilot_data_manager)


class PeriodCollectionDataEvent(Event):

    def __init__(self, config, seconds, data_collector: PeriodCollectDataEventInterface):
        super().__init__(config)
        self._table_name = data_collector.get_table_name()
        self._seconds = seconds
        self._data_collector = data_collector
        self._training_data_manager = PilotTrainDataManager(config)
        self._scheduler = scheduler = BackgroundScheduler()

        scheduler.add_job(self._trigger, "interval", seconds=self._seconds)

    def start(self):
        self._scheduler.start()

    def _trigger(self):
        column_2_value = self._data_collector.collect()
        self._training_data_manager.save_data(self._table_name, column_2_value)

    def stop(self):
        self._scheduler.shutdown()


class ContinuousCollectionDataEvent(Event):
    def __init__(self, config, data_collector: ContinuousCollectDataEventInterface):
        super().__init__(config)
        self._table_name = data_collector.get_table_name()
        self._data_collector = data_collector
        self._training_data_manager = PilotTrainDataManager(config)

    def start(self):
        while self._data_collector.has_next():
            column_2_value = self._data_collector.next()
            self._training_data_manager.save_data(self._table_name, column_2_value)


class PretrainingModelEvent(Event):
    def __init__(self, config: PilotConfig, pretraining_controller: PretrainingEventInterface):
        super().__init__(config)
        self.pretraining_controller = pretraining_controller

    def async_start(self):
        t = threading.Thread(target=self._run)
        t.start()
        return t

    def _run(self):
        self.pretraining_controller.collect_and_write()
        self.pretraining_controller.train()
