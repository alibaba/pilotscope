import threading
import time
import unittest

from apscheduler.schedulers.background import BackgroundScheduler
from pilotscope.PilotEvent import PeriodCollectionDataEvent
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEvent import PeriodCollectionDataEvent
from pilotscope.PilotSysConfig import PilotSysConfig

count = 0
def my_print():
    global count
    count += 1
    print("count {}".format(count))


class UserDataCollector(PeriodCollectionDataEvent):

    def get_table_name(self):
        return "collect_data_event_test"

    def custom_collect(self) -> dict:
        return {"name": "name1", "age": 18}


class MyTestCase(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()

    def test_event(self):
        collector = UserDataCollector(self.config, 0.1)
        collector.start()
        print("sleep")
        time.sleep(1)
        print("sleep end")
        collector.stop()

    def test_timer(self):
        scheduler = BackgroundScheduler()
        scheduler.add_job(my_print, "interval", seconds=0.1)
        scheduler.start()
        time.sleep(1)
        scheduler.shutdown()


if __name__ == '__main__':
    unittest.main()
