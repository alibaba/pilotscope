from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.DBController import BaseDBController
import tarfile
import os

from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum


class StatsTinyDataset(BaseDataset):
    """
    Random sample of STATS-CEB dataset and transfer timestamp columns to integer.
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL: "stats_tiny.sql",
                          DatabaseEnum.SPARK: None}
    sub_dir = "StatsTiny"
    train_sql_file = "stats_train_time2int.txt"
    test_sql_file = "stats_test_time2int.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, created_db_name="stats_tiny", data_dir = None) -> None:
        super().__init__(use_db_type, created_db_name, data_dir)
        self.data_file = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "stats_fast_sql_time2int.txt"))

    def load_to_db(self, config: PilotConfig):  # Overload
        config.db = self.created_db_name
        db_controller = DBControllerFactory.get_db_controller(config)
        self._load_dump(os.path.join(self.now_path, self.data_file), db_controller)
