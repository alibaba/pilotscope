from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.DBController import BaseDBController
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class ImdbDataset(BaseDataset):
    """
    IMDB dataset, a.k.a JOB dataset.
    V. Leis, A. Gubichev, A. Mirchev, P. Boncz, A. Kemper, and T. Neumann, ‘How Good Are Query Optimizers, Really?’,
    Proc. VLDB Endow., vol. 9, no. 3, pp. 204–215, Nov. 2015.
    """
    # download_url = "http://homepages.cwi.nl/~boncz/job/imdb.tgz"
    # data_sha256 = "25f9d893c54f903366e0c263f88db0d429dbc2b159d4987ebc1e203242a7e988"
    sub_dir = "Imdb"
    schema_file = "schematext.sql"
    train_sql_file = "job_train_ascii.txt"
    test_sql_file = "job_test.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, data_dir="./data") -> None:
        super().__init__(use_db_type, data_dir)

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "imdb_less_than_2_sec.txt"))

    def load_to_db(self, db_controller: BaseDBController):
        raise NotImplementedError
