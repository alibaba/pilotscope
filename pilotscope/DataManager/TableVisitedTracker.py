from pandas import DataFrame

from DBController.BaseDBController import BaseDBController
from PilotSysConfig import PilotSysConfig


class TableVisitedTracker:

    def __init__(self, db_controller: BaseDBController):
        self.db_controller = db_controller

        # The table records the "id" where the user last read from either "read_all" or "read_update".
        self.data_visit_table = PilotSysConfig.DATA_VISIT_RECORD_TABLE

        self.table_2_last_read_id = None

        # create table
        self.db_controller.create_table_if_absences(PilotSysConfig.DATA_VISIT_RECORD_TABLE, {
            "table_name": "",
            "last_read_id": 1
        }, primary_key_column="table_name", enable_autoincrement_id_key=False)

    def update_data_visit_id(self, table_name, cur_id):
        query = "select * from {} where table_name='{}'".format(self.data_visit_table, table_name)
        records = self.db_controller.execute(query, fetch=True)
        if len(records) > 0:
            query = "update {} set last_read_id={} where table_name='{}'".format(self.data_visit_table, cur_id,
                                                                                 table_name)
            self.db_controller.execute(query)
        else:
            query = "insert into {} (table_name, last_read_id) values ('{}', {})".format(self.data_visit_table,
                                                                                         table_name, cur_id)
            self.db_controller.execute(query)

    def read_data_visit_id(self, table_name):
        query = "select {} from {} where table_name='{}'".format("last_read_id", self.data_visit_table,
                                                                 table_name)
        res = DataFrame(self.db_controller.execute(query, fetch=True))
        if len(res) == 0:
            return None
        return int(res.at[res.index[0], res.columns[0]])

    def delete_visited_record(self, table):
        query = "delete from {} where table_name='{}'".format(self.data_visit_table, table)
        self.db_controller.execute(query)
