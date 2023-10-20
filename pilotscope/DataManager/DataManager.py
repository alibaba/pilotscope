import json
from copy import deepcopy

from pandas import DataFrame

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.PilotSysConfig import PilotSysConfig
from pilotscope.Common.Util import is_number


class DataManager:

    def __init__(self, config: PilotConfig) -> None:
        self.config = deepcopy(config)
        self.config.db = PilotSysConfig.USER_DATA_DB_NAME
        self.db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        self.table_primary_key = PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID
        self.collect_data_visit_table = PilotSysConfig.COLLECT_DATA_VISIT_RECORD_TABLE
        self.table_2_last_read_id = None
        self.db_controller.create_table_if_absences(PilotSysConfig.COLLECT_DATA_VISIT_RECORD_TABLE, {
            "table_name": "",
            "last_read_id": 1
        }, primary_key_column="table", enable_autoincrement_id_key=False)

    def _create_table_if_absence(self, table_name, column_2_value):
        # other
        if self.config.db_type != DatabaseEnum.SPARK:
            new_column_2_value = dict(column_2_value)
            new_column_2_value[self.table_primary_key] = 0
        else:
            new_column_2_value = column_2_value
        self.db_controller.create_table_if_absences(table_name, new_column_2_value,
                                                    primary_key_column=self.table_primary_key,
                                                    enable_autoincrement_id_key=True)

    def exist_table(self, table_name) -> bool:
        return self.db_controller.exist_table(table_name)

    def save_data(self, table_name, column_2_value):
        if len(column_2_value) > 0:
            self.db_controller.connect_if_loss()
            column_2_value = self._convert_data_type(column_2_value)
            self._create_table_if_absence(table_name, column_2_value)
            self.db_controller.insert(table_name, column_2_value)

    def save_data_batch(self, table_name, column_2_value_list):
        for i, column_2_value in enumerate(column_2_value_list):
            self.save_data(table_name, column_2_value)

    def _convert_data_type(self, column_2_value: dict):
        res = {}
        for key, value in column_2_value.items():
            if is_number(value) or isinstance(value, str):
                pass
            elif isinstance(value, dict):
                value = json.dumps(value)
            else:
                raise RuntimeError(
                    "the data written into table should be number, dict and str, the {} is not allowed".format(
                        type(value)))
            res[key] = value
        return res

    def get_table_row_count(self, table_name):
        return self.db_controller.get_table_row_count(table_name)

    def read_all(self, table_name):
        query = "select * from {}".format(table_name)
        self.db_controller.connect_if_loss()  #
        res = DataFrame(self.db_controller.execute(query, fetch=True))

        # update id
        if self.config.db_type != DatabaseEnum.SPARK:
            cur_id = self._extract_max_id(res)
            self._update_table_last_id(table_name, cur_id)

        return res

    def read_update(self, table_name):
        last_id = self._get_table_last_id(table_name)
        last_id = -1 if last_id is None else last_id

        query = "select * from {} where {} > {}".format(table_name, self.table_primary_key, last_id)
        res = DataFrame(self.db_controller.execute(query, fetch=True))

        # update id
        if len(res) > 0:
            cur_id = self._extract_max_id(res)
            self._update_table_last_id(table_name, cur_id)

        return res

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

    def _extract_max_id(self, df: DataFrame):
        return int(df.at[df.index[-1], PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID])

    def _get_table_last_id(self, table):
        return self.read_training_data_visit_id(table)

    def _update_table_last_id(self, table, cur_id):
        self.update_training_data_visit_id(table, cur_id)
