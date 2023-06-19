from copy import deepcopy

from pandas import DataFrame
from sqlalchemy import select, Table

from DBController.BaseDBController import BaseDBController
from Dao.PilotUserDataManager import PilotUserDataManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotSysConfig import PilotSysConfig


class PilotTrainDataManager:

    def __init__(self, config: PilotConfig) -> None:
        self.config = deepcopy(config)
        self.config.db = PilotSysConfig.USER_DATA_DB_NAME
        self.db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)
        self.user_data_manager = PilotUserDataManager(self.config)
        self.table_primary_key = PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID

    def create_table_if_absence(self, table_name, column_2_value):
        # other
        new_column_2_value = dict(column_2_value)
        new_column_2_value[self.table_primary_key] = 0
        self.db_controller.create_table_if_absences(table_name, new_column_2_value,
                                                    primary_key_column=self.table_primary_key,
                                                    enable_autoincrement_id_key=True)

    def exist_table(self, table_name) -> bool:
        return self.db_controller.exist_table(table_name)

    def save_data(self, table_name, column_2_value):
        if len(column_2_value) > 0:
            print("enter")
            self.create_table_if_absence(table_name, column_2_value)
            self.insert(table_name, column_2_value)

    def insert(self, table_name, column_2_value: dict):
        self.db_controller.insert(table_name, column_2_value)

    def query_row_count(self, table_name):
        return self.db_controller.get_table_row_count(table_name)

    def read_all(self, table_name):
        table: Table = self.db_controller.get_sqla_table(table_name)
        query = select(table)
        res = self.db_controller.get_data(query)

        # update id
        cur_id = self._extract_max_id_from_df(res)
        self._update_table_last_id(table_name, cur_id)

        return res

    def read_update(self, table_name):
        table: Table = self.db_controller.get_sqla_table(table_name)
        last_id = self._read_table_last_id(table_name)
        if last_id is None:
            last_id = -1
        # res = self.db_controller. get_data_with_larger_id(table_name, last_id)
        query = select(table).where(getattr(table.c, self.table_primary_key) > last_id)
        res = self.db_controller.get_data(query)

        # update id
        if len(res) > 0:
            cur_id = self._extract_max_id_from_df(res)
            self._update_table_last_id(table_name, cur_id)

        return res

    def _extract_max_id_from_df(self, df: DataFrame):
        return int(df.at[df.index[-1], PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID])

    def _read_table_last_id(self, table):
        return self.user_data_manager.read_training_data_visit_id(table)

    def _update_table_last_id(self, table, cur_id):
        self.user_data_manager.update_training_data_visit_id(table, cur_id)
