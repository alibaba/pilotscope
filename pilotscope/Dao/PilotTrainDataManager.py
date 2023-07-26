import json
from copy import deepcopy

from pandas import DataFrame
from sqlalchemy import select, Table

from DBController.BaseDBController import BaseDBController
from Dao.PilotUserDataManager import PilotUserDataManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from PilotSysConfig import PilotSysConfig
from common.Util import is_number


class PilotTrainDataManager:

    def __init__(self, config: PilotConfig) -> None:
        self.config = deepcopy(config)
        self.config.db = PilotSysConfig.USER_DATA_DB_NAME
        self.db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        self.user_data_manager = PilotUserDataManager(self.config)
        self.table_primary_key = PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID

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
        res = DataFrame(self.db_controller.execute(query, fetch=True))

        # update id
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

    def _extract_max_id(self, df: DataFrame):
        return int(df.at[df.index[-1], PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID])

    def _get_table_last_id(self, table):
        return self.user_data_manager.read_training_data_visit_id(table)

    def _update_table_last_id(self, table, cur_id):
        self.user_data_manager.update_training_data_visit_id(table, cur_id)
