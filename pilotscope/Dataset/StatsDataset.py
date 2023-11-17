from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.DBController import BaseDBController
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class StatsDataset(BaseDataset):
    """
    """
    download_urls_dict = {DatabaseEnum.POSTGRESQL : ["https://github.com/weiwch/ai4db_datasets/releases/download/stats/postgres_stats.tar.gz"],
                          DatabaseEnum.SPARK : None}
    data_sha256 = "f557545c3fcf449eab02f2f3b91b13dffd814254c32536e3f96bc20e0b6991bb"
    sub_dir = "Stats"
    schema_file = ""
    train_sql_file = "stats_train.txt"
    test_sql_file = "stats_test.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, data_dir="data") -> None:
        super().__init__(use_db_type, data_dir)
        self.download_urls = self.download_urls_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "imdb_less_than_2_sec.txt"))

