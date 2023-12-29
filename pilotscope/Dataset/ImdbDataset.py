from pilotscope.Dataset.BaseDataset import BaseDataset
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class ImdbDataset(BaseDataset):
    """
    IMDB dataset, a.k.a JOB dataset.
    V. Leis, A. Gubichev, A. Mirchev, P. Boncz, A. Kemper, and T. Neumann, ‘How Good Are Query Optimizers, Really?’, Proc. VLDB Endow., vol. 9, no. 3, pp. 204–215, Nov. 2015.
    The data of IMDB is from http://homepages.cwi.nl/~boncz/job/imdb.tgz
    The license and links to the current version IMDB data set can be found at http://www.imdb.com/interfaces
    Query and index are from https://github.com/gregrahn/join-order-benchmark
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL: [
        "https://github.com/weiwch/ai4db_datasets/releases/download/imdb/postgres_imdb.tar.gz"],
        DatabaseEnum.SPARK: None}
    data_sha256 = "03ff2e51e479fddae0fd4a0a40a51fad78536bde5bba3bdc9f49563be96f9b12"
    sub_dir = "Imdb"
    train_sql_file = "job_train_ascii.txt"
    test_sql_file = "job_test.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, created_db_name="imdb", data_dir="./data") -> None:
        super().__init__(use_db_type, created_db_name, data_dir)
        self.download_urls = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "imdb_fast_sql.txt"))
