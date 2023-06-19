from copy import deepcopy

from pandas import DataFrame
from sqlalchemy import Table, select, update, insert

from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotSysConfig import PilotSysConfig


def singleton(class_):
    instances = {}

    def getinstance(*args, **kwargs):
        if class_ not in instances:
            instances[class_] = class_(*args, **kwargs)
        return instances[class_]

    return getinstance


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
            "table": "",
            "last_read_id": 1
        }, primary_key_column="table")

    def update_training_data_visit_id(self, table_name, cur_id):
        table: Table = self.db_controller.get_sqla_table(self.collect_data_visit_table)
        print("dsadsadasda2")
        exist_data: DataFrame = self.db_controller.get_data(select(table).where(table.c.table == table_name))
        print("dsadsadasda")
        if len(exist_data.index) > 0:
            self.db_controller.update_data(update(table).where(table.c.table == table_name).values(last_read_id=cur_id))
            pass
        else:
            self.db_controller.update_data(insert(table).values(table=table_name, last_read_id=cur_id))

    def read_training_data_visit_id(self, table_name):
        table: Table = self.db_controller.get_sqla_table(self.collect_data_visit_table)
        if table is None:
            return None
        res: DataFrame = self.db_controller.get_data(
            select(table.c.last_read_id).where(table.c.table == table_name))
        return int(res.at[res.index[0], res.columns[0]])
