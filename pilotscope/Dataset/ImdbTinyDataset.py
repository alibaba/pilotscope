from pilotscope.Dataset.BaseDataset import BaseDataset
from pilotscope.DBController import BaseDBController
import tarfile
import os

from pilotscope.PilotEnum import DatabaseEnum


class ImdbTinyDataset(BaseDataset):
    """
    Random sample of IMDB dataset.
    Its queries are same as `ImdbDataset`.
    """
    data_location_dict = {DatabaseEnum.POSTGRESQL : "imdb_tiny.sql",
                          DatabaseEnum.SPARK : None}
    sub_dir = "Imdb" # Because the schema is exactly same, we reuse the folder.
    train_sql_file = "job_train_ascii.txt"
    test_sql_file = "job_test.txt"
    now_path = os.path.join(os.path.dirname(__file__), sub_dir)
    file_db_type = DatabaseEnum.POSTGRESQL

    def __init__(self, use_db_type: DatabaseEnum, data_dir="data") -> None:
        super().__init__(use_db_type, data_dir)
        self.data_file = self.data_location_dict[use_db_type]

    def test_sql_fast(self):
        return self._get_sql(os.path.join(self.now_path, "imdb_less_than_2_sec.txt"))
    
    def load_to_db(self, db_controller: BaseDBController): # Overload
        self._load_dump(os.path.join(self.now_path, self.data_file), db_controller)

