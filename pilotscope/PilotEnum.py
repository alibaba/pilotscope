from enum import Enum


class PilotEnum(Enum):
    def __eq__(self, *args, **kwargs):
        return self.name == args[0].name

    def __hash__(self, *args, **kwargs):
        return hash(self.name)


class DatabaseEnum(PilotEnum):
    POSTGRESQL = 0,
    SPARK = 1


class HintEnum(PilotEnum):
    ENABLE_HASH_JOIN = 0


class PushHandlerTriggerLevelEnum(PilotEnum):
    WORKLOAD = 0,
    QUERY = 1


class EventEnum(PilotEnum):
    PERIOD_TRAIN_EVENT = 0
    PERIODIC_TRAINING_EVENT = 1,
    PERIODIC_COLLECTION_EVENT = 2,
    PRETRAINING_EVENT = 3,
    PERIODIC_DB_CONTROLLER_EVENT = 5


class DataFetchMethodEnum(PilotEnum):
    HTTP = 0


class FetchMethod(PilotEnum):
    INNER = 0,
    OUTER = 1,


class TrainSwitchMode(PilotEnum):
    WAIT = 0,
    DB = 1


class ExperimentTimeEnum:
    PIPE_END_TO_END = "PIPEEndToEnd"
    SQL_END_TO_END = "SQLEndToEnd"


class SparkSQLDataSourceEnum(PilotEnum):
    CSV = "csv"
    JSON = "json"
    PARQUET = "parquet"
    HIVE = "hive"
    POSTGRESQL = "postgresql"
