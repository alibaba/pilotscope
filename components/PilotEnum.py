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


class ReplaceAnchorTriggerEnum(PilotEnum):
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


class AllowedFetchDataEnum(PilotEnum):
    PHYSICAL_PLAN = "physical_plan",
    LOGICAL_PLAN = "logical_plan",
    EXECUTION_TIME = "execution_time",
    REAL_COST_SUBPLAN = "real_cost_subplan",
    REAL_CARD_SUBQUERY = "real_card_subquery",
    SUBQUERY_2_CARDS = "subquery_2_cards",
    HINTS = "hints",


class FetchMethod(PilotEnum):
    INNER = 0,
    OUTER = 1,


class TrainSwitchMode(PilotEnum):
    WAIT = 0,
    DB = 1


class ExperimentTimeEnum:
    PIPE_END_TO_END = "PIPEEndToEnd"
    SQL_END_TO_END = "SQLEndToEnd"
    AI_TASK = "AiTask"
    WRITE_TABLE = "Write"
    SQL_TOTAL_TIME = "Sql"
    Db_SQL_TIME = "DbSql"
    DB_PARSER = "Parser"
    DB_HTTP = "Http"
    ANCHOR = "{}"
    REMAIN = "Remain"
    PREDICT = "Predict"
    FIND_INDEX = "FindIndex"
    FIND_KNOB = "FindKnob"

    @classmethod
    def get_anchor_key(cls, anchor_name):
        return ExperimentTimeEnum.ANCHOR.format(anchor_name.split("_")[0])


class SparkSQLDataSourceEnum(PilotEnum):
    CSV = "csv"
    JSON = "json"
    PARQUET = "parquet"
    HIVE = "hive"
    POSTGRESQL = "postgresql"
