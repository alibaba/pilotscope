from pilotscope.DBController import BaseDBController
from pilotscope.Dataset.BaseDataset import BaseDataset
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class TpcdsDataset(BaseDataset):
    """
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL: [],
                          DatabaseEnum.SPARK: None}
    data_sha256 = ""
    sub_dir = "Tpcds"
    train_sql_file = "tpcds_train_sql.txt"
    test_sql_file = "tpcds_test_sql.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, created_db_name="tpcds", data_dir="./data") -> None:
        super().__init__(use_db_type, created_db_name, data_dir)
        self.download_urls = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "tpcds_less_than_0_point_2_sec.txt"))

    def load_to_db(self, db_controller: BaseDBController):
        raise NotImplementedError
