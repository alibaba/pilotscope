from enum import Enum


class PilotEnum(Enum):
    def __eq__(self, *args, **kwargs):
        return self.name == args[0].name

    def __hash__(self, *args, **kwargs):
        return hash(self.name)


class DatabaseEnum(PilotEnum):
    POSTGRESQL = 0,
    SPARK = 1


class PushHandlerTriggerLevelEnum(PilotEnum):
    WORKLOAD = 0,
    QUERY = 1


class DataFetchMethodEnum(PilotEnum):
    HTTP = 0


class FetchMethod(PilotEnum):
    INNER = 0,
    OUTER = 1,


class TrainSwitchMode(PilotEnum):
    WAIT = 0,
    DB = 1


class SparkSQLDataSourceEnum(PilotEnum):
    POSTGRESQL = "postgresql"
