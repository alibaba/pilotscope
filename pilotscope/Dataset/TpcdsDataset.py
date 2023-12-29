from pilotscope.DBController import BaseDBController
from pilotscope.Dataset.BaseDataset import BaseDataset
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class TpcdsDataset(BaseDataset):
    """
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL: [
        "https://github.com/weiwch/ai4db_datasets/releases/download/tpch/postgres_tpch.tar.gz"],
        DatabaseEnum.SPARK: None}
    data_sha256 = "bd42b29a73fe854023f99733c394e490cd14fcf891669c9abd33178b3283f072"
    sub_dir = "Tpcds"
    train_sql_file = "tpcds_train_sql.txt"
    test_sql_file = "tpcds_test_sql.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, created_db_name="tpcds", data_dir="./data") -> None:
        super().__init__(use_db_type, created_db_name, data_dir)
        self.download_urls = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "tpcds_fast_sql.txt"))

