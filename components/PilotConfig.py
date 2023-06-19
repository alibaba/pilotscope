import os

from PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode


class PilotConfig:

    def __init__(self) -> None:
        self.db_type: DatabaseEnum = DatabaseEnum.POSTGRESQL
        self.pilotscope_core_url = "localhost"
        self.host = "localhost"
        self.user = "postgres"
        self.db = "stats"
        self.SEP = "###"
        self.data_fetch_method = DataFetchMethodEnum.HTTP
        self.once_request_timeout = 200
        self.http_port = 54523

        # example
        self.stats_train_sql_file_path = "../examples/stats_train_10_sql.txt"

        # pretraining
        self.pretraining_model = TrainSwitchMode.WAIT

    def set_db_type(self, db):
        self.db_type = db
        pass
