from abc import ABC, abstractmethod
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.Dataset.Utils import database_enum_to_sqlglot_str
from pilotscope.DBController import BaseDBController
import sqlglot
from requests import get
import os
import hashlib

class BaseDataset(ABC):
    
    data_sha256 = None
    def __init__(self, file_db_type:DatabaseEnum, use_db_type:DatabaseEnum, data_dir = "./data") -> None:
        self.file_db_type = file_db_type
        self.use_db_type = use_db_type
        self.data_dir = data_dir # modify to __file__ or other dir
        
    def _get_sql(self, file_path, pre_line = True):
        with open(file_path, "r") as f:
            if(self.use_db_type  == self.file_db_type):
                if(pre_line):
                    return f.readlines()
                else:
                    return f.read().split(";")[:-1] # what is after last ; is white space 
            else:
                if(pre_line):
                    return [sqlglot.transpile(sql, database_enum_to_sqlglot_str(self.file_db_type),database_enum_to_sqlglot_str(self.use_db_type ))[0] for sql in f.readlines()]
                else:
                    return sqlglot.transpile(f.read(), database_enum_to_sqlglot_str(self.file_db_type),database_enum_to_sqlglot_str(self.use_db_type))
    
    @abstractmethod
    def schematext(self):
        pass
    
    @abstractmethod
    def train_sql():
        pass
    
    @abstractmethod
    def test_sql():
        pass
    
    def create_dataset_tables(self, db_controler: BaseDBController):
        for sql in self.schematext():
            db_controler.execute(sql)
    
    
    def _download_save(self, url, save_name):
        dir_and_filename = os.path.join(self.data_dir,save_name)
        if(os.path.isfile(dir_and_filename)):
            if(self._hash_data(save_name) == self.data_sha256):
                return
            else:
                print("Hash of existed file is not same, redownload!")
        response = get(url)
        with open(dir_and_filename, "wb") as file:
            file.write(response.content)
        assert(self._hash_data(save_name) == self.data_sha256)

    def _hash_data(self, filename):
        h  = hashlib.sha256()
        b  = bytearray(128*1024)
        mv = memoryview(b)
        with open(os.path.join(self.data_dir, filename), 'rb', buffering=0) as f:
            for n in iter(lambda : f.readinto(mv), 0):
                h.update(mv[:n])
        return h.hexdigest()
    
    def _copy_from_csv(self, folder_dir, db_controler: BaseDBController):
        if db_controler.config.db_type == DatabaseEnum.POSTGRESQL:
            file_names = os.listdir(folder_dir)
            conn = db_controler.connection_thread.conn.connection
            cursor = conn.cursor()
            for file_name in file_names:
                if(file_name.endswith(".csv")):
                    path_and_name = os.path.join(folder_dir,file_name)
                    with open(path_and_name) as f:
                        print(f"copy {file_name} to database {db_controler.config.db}")
                        table_name = file_name.split(".")[0]
                        # print(f"copy {table_name} from '{os.path.abspath(path_and_name)}' with csv delimiter ',' quote '\"' escape '\\';")
                        cursor.copy_expert(f"copy {table_name} from '{os.path.abspath(path_and_name)}' with csv delimiter ',' quote '\"' escape '\\';",f)
                        os.remove(path_and_name)
        else:
            raise NotImplementedError