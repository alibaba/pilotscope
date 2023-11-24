from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.DBController import BaseDBController
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class StatsTinyDataset(BaseDataset):
    """
    Random sample of STATS-CEB dataset and transfer timestamp columns to integer.
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL : "stats_tiny.sql",
                          DatabaseEnum.SPARK : None}
    sub_dir = "StatsTiny"
    train_sql_file = "stats_train_time2int.txt"
    test_sql_file = "stats_test_time2int.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, data_dir="data") -> None:
        super().__init__(use_db_type, data_dir)
        self.data_file = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "stats_less_than_2_sec_time2int.txt"))
    
    def load_to_db(self, db_controller: BaseDBController): # Overload
        self._load_dump(os.path.join(self.now_path, self.data_file), db_controller)

