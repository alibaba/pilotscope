import threading
import time
import unittest

from apscheduler.schedulers.background import BackgroundScheduler
from Interface.PeriodCollectDataEventInterface import PeriodCollectDataEventInterface
from PilotConfig import PilotConfig
from PilotEvent import PeriodCollectionDataEvent
from PilotSysConfig import PilotSysConfig

count = 0


class UserDataCollector(PeriodCollectDataEventInterface):

    def get_table_name(self):
        return "collect_data_event_test"

    def custom_collect(self) -> dict:
        return {"name": "name1", "age": 18}


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PilotConfig()

    def test_event(self):
        collector = UserDataCollector()
        self.event = PeriodCollectionDataEvent(self.config, 1, collector)
        self.event.start()
        print("sleep")
        time.sleep(10)
        print("sleep end")

    def test_timer(self):
        scheduler = BackgroundScheduler()
        scheduler.add_job(my_print, "interval", seconds=1)
        scheduler.start()
        time.sleep(10)


if __name__ == '__main__':
    unittest.main()


def my_print():
    global count
    count += 1
    print("count {}".format(count))
