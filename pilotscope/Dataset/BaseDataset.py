from abc import ABC, abstractmethod

from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.Dataset.Utils import database_enum_to_sqlglot_str
from pilotscope.DBController import BaseDBController
from pilotscope.Common.SSHConnector import SSHConnector
import sqlglot
import wget
import appdirs
import os
import hashlib
import tarfile


class BaseDataset(ABC):
    data_sha256 = None  # hash value of the downloaded file. To make sure the file is exactly same.
    data_location_dict = None
    download_urls = None
    sub_dir = None
    schema_file = None
    train_sql_file = None
    test_sql_file = None
    file_db_type = None

    def __init__(self, use_db_type: DatabaseEnum, created_db_name, data_dir = None) -> None:
        self.use_db_type = use_db_type
        if data_dir is None:
           self.data_dir = os.path.join(appdirs.user_data_dir(),"pilotscope_data/")
        else:
            self.data_dir = data_dir
        os.makedirs(self.data_dir, exist_ok=True)
        self.now_path = os.path.join(os.path.dirname(__file__), self.sub_dir)
        self.created_db_name = created_db_name

    def _get_sql(self, file_path):
        with open(file_path, "r") as f:
            if self.use_db_type == self.file_db_type:
                return f.read().split(";")[:-1]  # what is after last ; is white space
            else:
                return sqlglot.transpile(f.read(), database_enum_to_sqlglot_str(self.file_db_type),
                                         database_enum_to_sqlglot_str(self.use_db_type))

    def read_schema(self):
        return self._get_sql(os.path.join(self.now_path, self.schema_file))

    def read_train_sql(self):
        return self._get_sql(os.path.join(self.now_path, self.train_sql_file))

    def read_test_sql(self):
        return self._get_sql(os.path.join(self.now_path, self.test_sql_file))

    def _download_dataset(self, urls):
        merged_fname = urls[0].split("/")[-1].split(".")[0] + ".tar.gz"
        merged_dir_and_fname = os.path.join(self.data_dir, merged_fname)
        if os.path.isfile(merged_dir_and_fname) and self._hash_data(merged_dir_and_fname) == self.data_sha256:
            return merged_fname
        fnames = []
        for url in urls:
            fnames.append(self._download_save(url))
        self._merge_files(fnames, merged_dir_and_fname)
        assert(os.path.isfile(merged_dir_and_fname))
        if self._hash_data(merged_fname) == self.data_sha256:
            return merged_fname
        else:
            print("Hash of existed file is not same, redownload!")
            return self._download_dataset(self.download_urls)

    def _download_save(self, url):
        dir_and_filename = os.path.join(self.data_dir, url.split("/")[-1])
        print("Downloading: ", end="")
        wget.download(url, self.data_dir)
        return dir_and_filename

    def _hash_data(self, file_dir):
        h = hashlib.sha256()
        b = bytearray(128 * 1024)
        mv = memoryview(b)
        with open(file_dir, 'rb', buffering=0) as f:
            for n in iter(lambda: f.readinto(mv), 0):
                h.update(mv[:n])
        return h.hexdigest()

    def _merge_files(self, fnames, merged_fname):
        if len(fnames) == 1:
            return
        else:
            with open(merged_fname, "wb") as writer:
                for fname in fnames:
                    with open(fname, "rb") as f:
                        writer.write(f.read())

    def _load_dump(self, dump_file_dir, db_controller: BaseDBController):
        if self.use_db_type == DatabaseEnum.POSTGRESQL:
            psql = os.path.join(db_controller.config.pg_bin_path, "psql")
            if db_controller.config.is_local:
                os.system(f"{psql} {self.created_db_name} -U {db_controller.config.db_user} < {dump_file_dir}")
            else:
                ssh_conn = SSHConnector(db_controller.config.db_host, db_controller.config.db_host_user, db_controller.config.db_host_pwd, db_controller.config.db_host_port)
                ssh_conn.connect()
                with open(dump_file_dir, "r") as f:
                    remote_file_dir = os.path.join(db_controller.config.pgdata,os.path.split(dump_file_dir)[1])
                    ssh_conn.write_file(remote_file_dir, f.read())
                    ssh_conn.remote_exec_cmd(f"{psql} {self.created_db_name} -U {db_controller.config.db_user} < {remote_file_dir}")
                ssh_conn.close()
        else:
            raise NotImplementedError

    def load_to_db(self, config: PilotConfig):
        fname = self._download_dataset(self.download_urls)
        tf = tarfile.open(os.path.join(self.data_dir, fname))
        extract_folder = os.path.join(self.data_dir, fname + ".d")
        if not os.path.isdir(extract_folder):
            os.mkdir(extract_folder)
        tf.extractall(extract_folder)
        dump_file_name = os.listdir(extract_folder)[0]

        config.db = self.created_db_name
        db_controller = DBControllerFactory.get_db_controller(config)
        self._load_dump(os.path.join(extract_folder, dump_file_name), db_controller)

    def _copy_from_csv(self, folder_dir, db_controller: BaseDBController):
        if db_controller.config.db_type == DatabaseEnum.POSTGRESQL:
            file_names = os.listdir(folder_dir)
            conn = db_controller.connection_thread.conn.connection
            cursor = conn.cursor()
            for file_name in file_names:
                if file_name.endswith(".csv"):
                    path_and_name = os.path.join(folder_dir, file_name)
                    with open(path_and_name) as f:
                        print(f"copy {file_name} to database {db_controller.config.db}")
                        table_name = file_name.split(".")[0]
                        # print(f"copy {table_name} from '{os.path.abspath(path_and_name)}' with csv delimiter ',' quote '\"' escape '\\';")
                        cursor.copy_expert(
                            f"copy {table_name} from '{os.path.abspath(path_and_name)}' with csv delimiter ',' quote '\"' escape '\\';",
                            f)
                        os.remove(path_and_name)
        else:
            raise NotImplementedError
