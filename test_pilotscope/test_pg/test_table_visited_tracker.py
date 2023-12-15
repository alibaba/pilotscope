from unittest import TestCase

from pilotscope.DataManager.DataManager import TableVisitedTracker
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotSysConfig import PilotSysConfig


class TestTableVisitedTracker(TestCase):
    def __init__(self, methodName='TestTableVisitedTracker'):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = self.config.user_data_db_name
        self.table_visited_tracker = TableVisitedTracker(DBControllerFactory.get_db_controller(config=self.config))
        self.test_table = "table_visited_tracker_test_table"

    def test_update_data_visit_id(self):
        self.table_visited_tracker.delete_visited_record(self.test_table)

        # insert record
        self.table_visited_tracker.update_data_visit_id(self.test_table, 10)
        self.assertTrue(self.table_visited_tracker.read_data_visit_id(self.test_table) == 10)

        # update record
        self.table_visited_tracker.update_data_visit_id(self.test_table, 11)
        self.assertTrue(self.table_visited_tracker.read_data_visit_id(self.test_table) == 11)

    def test_read_training_data_visit_id(self):
        self.table_visited_tracker.delete_visited_record(self.test_table)

        # insert record
        self.table_visited_tracker.update_data_visit_id(self.test_table, 10)
        self.assertTrue(self.table_visited_tracker.read_data_visit_id(self.test_table) == 10)

    def test_delete_visited_record(self):
        # insert record
        self.table_visited_tracker.update_data_visit_id(self.test_table, 10)

        # clear record
        self.table_visited_tracker.delete_visited_record(self.test_table)

        self.assertTrue(self.table_visited_tracker.read_data_visit_id(self.test_table) is None)
