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
    """
    This class provides methods to interact with a database to store and retrieve data.
    """
    def __init__(self, config: PilotConfig) -> None:
        self.config = deepcopy(config)

        self.config.db = PilotSysConfig.USER_DATA_DB_NAME

        self.db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)

        # pilotscope add a primary key for all user tables.
        self.table_primary_key = PilotSysConfig.DATA_COLLECT_TABLE_PRIMARY_ID

        self.table_visited_tracker = TableVisitedTracker(self.db_controller)

    def exist_table(self, table_name) -> bool:
        """
        Check if a table exists in the database.

        :param table_name: The name of the table to check.
        :type table_name: str

        :return: True if the table exists, False otherwise.
        :rtype: bool
        """
        return self.db_controller.exist_table(table_name)

    def save_data(self, table_name, column_2_value):
        """
        Save data to the specified table in the database.

        :param table_name: The name of the table to insert the data into.
        :type table_name: str
        :param column_2_value: A dictionary of column names and their corresponding values, e.g. {'id': 1, 'name': 'John Doe', 'email': 'john.doe@example.com'}
        :type column_2_value: Dict[str, Any]
        """
        if len(column_2_value) > 0:
            self.db_controller.connect_if_loss()
            column_2_value = self._convert_data_type(column_2_value)
            self.create_table_if_absence(table_name, column_2_value)
            self.db_controller.insert(table_name, column_2_value)

    def drop_table_if_exist(self, table_name):
        """
        Drop the table if it exists.

        :param table_name: The name of the table to be dropped.
        :type table_name: str
        """  
        if self.exist_table(table_name):
            self.db_controller.drop_table_if_exist(table_name)
            self.table_visited_tracker.delete_visited_record(table_name)

    def save_data_batch(self, table_name, column_2_value_list):
        """
        Save data batch.

        :param table_name: The name of the table to be saved.
        :type table_name: str

        :param column_2_value_list: A list of dictionaries, where each dictionary represents one row of data, e.g. [{'id': 1, 'name': 'John Doe', 'email': 'john.doe@example.com'}, {'id': 2, 'name': 'Jane Doe', 'email': 'jane.doe@example.com'}]
        :type column_2_value_list: List[Dict[str, Any]]

        :return: None
        :rtype: NoneType
        """ 
        for i, column_2_value in enumerate(column_2_value_list):
            self.save_data(table_name, column_2_value)

    def get_table_row_count(self, table_name):
        """
        Get the number of rows in a given table.

        :param table_name: The name of the table whose row count is needed.
        :type table_name: str

        :return: The number of rows in the given table.
        :rtype: int
        """  
        return self.db_controller.get_table_row_count(table_name)

    def read_all(self, table_name):
        """
        Read all rows from a given table.

        :param table_name: The name of the table to read from.
        :type table_name: str
        
        :return: All rows in the specified table as a pandas DataFrame.
        :rtype: pandas.DataFrame
        """  
        query = "select * from {}".format(table_name)
        data = DataFrame(self.db_controller.execute(query, fetch=True))

        self._update_visited_record(table_name, data)
        return data

    def read_update(self, table_name):
        """
        Read and update the visited record of a given table.

        :param table_name: The name of the table to read and update.
        :type table_name: str
        
        :return: The new rows in the specified table since the last visit as a pandas DataFrame.
        :rtype: pandas.DataFrame
        """  
        if self.config.db_type == DatabaseEnum.SPARK:
            raise RuntimeError("spark not support read_update")

        last_id = self.table_visited_tracker.read_data_visit_id(table_name)
        last_id = -1 if last_id is None else last_id

        query = "select * from {} where {} > {}".format(table_name, self.table_primary_key, last_id)
        data = DataFrame(self.db_controller.execute(query, fetch=True))

        self._update_visited_record(table_name, data)
        return data

    def create_table_if_absence(self, table_name, column_2_value):
        """
        Create a table if it does not exist.

        :param table_name: The name of the table to create.
        :type table_name: str

        :param column_2_value: A dictionary representing the columns and their default values for the new table, e.g. {'id': 0, 'name': '', 'email': ''}
        :type column_2_value: Dict[str, Any]
        """   
        if self.config.db_type != DatabaseEnum.SPARK:
            new_column_2_value = dict(column_2_value)
            new_column_2_value[self.table_primary_key] = 0
        else:
            new_column_2_value = column_2_value
        self.db_controller.create_table_if_absences(table_name, new_column_2_value,
                                                    primary_key_column=self.table_primary_key,
                                                    enable_autoincrement_id_key=True)

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

    def _update_visited_record(self, table_name, records):
        # update id
        if self.config.db_type != DatabaseEnum.SPARK:
            cur_id = self._extract_max_id(records)
            if cur_id is not None:
                self.table_visited_tracker.update_data_visit_id(table_name, cur_id)

    def _extract_max_id(self, data: DataFrame):
        if len(data) == 0:
            return None
        return int(data.at[data.index[-1], self.table_primary_key])


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
