from copy import deepcopy

from pandas import DataFrame
from sqlalchemy import Table, select, update, insert

from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotSysConfig import PilotSysConfig
from common.Util import singleton


@singleton
class PilotUserDataManager:
    def __init__(self, config: PilotConfig):
        super().__init__()
        self.config = deepcopy(config)
        self.config.db = PilotSysConfig.USER_DATA_DB_NAME

        self.db_controller = DBControllerFactory.get_db_controller(self.config, allow_to_create_db=True)

        # user data needed to be saved
        self.collect_data_visit_table = PilotSysConfig.COLLECT_DATA_VISIT_RECORD_TABLE
        self.table_2_last_read_id = None
        self.db_controller.create_table_if_absences(PilotSysConfig.COLLECT_DATA_VISIT_RECORD_TABLE, {
            "table_name": "",
            "last_read_id": 1
        }, primary_key_column="table", enable_autoincrement_id_key=False)

    def update_training_data_visit_id(self, table_name, cur_id):
        query = "select * from {} where table_name='{}'".format(self.collect_data_visit_table, table_name)
        exist_data = DataFrame(self.db_controller.execute(query, fetch=True))
        if len(exist_data.index) > 0:
            query = "update {} set last_read_id={} where table_name='{}'".format(self.collect_data_visit_table, cur_id,
                                                                                 table_name)
            self.db_controller.execute(query)
        else:
            query = "insert into {} (table_name, last_read_id) values ('{}', {})".format(self.collect_data_visit_table,
                                                                                         table_name, cur_id)
            self.db_controller.execute(query)

    def read_training_data_visit_id(self, table_name):
        query = "select {} from {} where table_name='{}'".format("last_read_id", self.collect_data_visit_table,
                                                                 table_name)
        res = DataFrame(self.db_controller.execute(query, fetch=True))
        if len(res) == 0:
            return None
        return int(res.at[res.index[0], res.columns[0]])
