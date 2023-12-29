from pilotscope.Dataset.BaseDataset import BaseDataset
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class StatsDataset(BaseDataset):
    """
    STATS-CEB dataset.
    Yuxing Han, Ziniu Wu, Peizhi Wu, Rong Zhu, Jingyi Yang, Tan Wei Liang, Kai Zeng, Gao Cong, Yanzhao Qin, Andreas Pfadler, Zhengping Qian, Jingren Zhou, Li Jiangneng, and Bin Cui. 2022. Cardinality Estimation in DBMS: A Comprehensive Benchmark Evaluation. VLDB 15, 4 (2022).
    The original STATS dataset can be found in https://relational.fit.cvut.cz/dataset/Stats.
    The data, indexes and quiries used for AI for DB are from https://github.com/Nathaniel-Han/End-to-End-CardEst-Benchmark/
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL: [
        "https://github.com/weiwch/ai4db_datasets/releases/download/stats/postgres_stats.tar.gz"],
                          DatabaseEnum.SPARK: None}
    data_sha256 = "4079854d51034e5aedcaaea6a23ef967ecd0f0cce559781cb825334760a6152a"
    sub_dir = "Stats"
    train_sql_file = "stats_train.txt"
    test_sql_file = "stats_test.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, created_db_name="stats", data_dir = None) -> None:
        super().__init__(use_db_type, created_db_name, data_dir)
        self.download_urls = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "stats_fast_sql.txt"))
