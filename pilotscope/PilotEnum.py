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

class ScanJoinMethodEnum(PilotEnum):
    # Scan method of pg_hint_plan, find detailed description in https://github.com/ossc-db/pg_hint_plan/blob/master/docs/hint_list.md
    SEQ = "SeqScan"
    TID = "TidScan"
    INDEX = "IndexScan"
    INDEXONLY = "IndexOnlyScan"
    BITMAP = "BitmapScan"
    NOSEQ = "NoSeqScan"
    NOTID = "NoTidScan"
    NOINDEX = "NoIndexScan"
    NOINDEXONLY = "NoIndexOnlyScan"
    NOBITMAP = "NoBitmapScan"
    PARALLEL = "Parallel"
    ROW = "Row"
    # Join method of pg_hint_plan
    NESTLOOP = "NestLoop"
    HASHJOIN = "HashJoin"
    MERGEJOIN = "MergeJoin"
    MEMOIZE = "Memoize"
    NONESTLOOP = "NoNestLoop"
    NOHASHJOIN = "NoHashJoin"
    NOMERGEJOIN = "NoMergeJoin"
    NOMEMOIZE = "NoMemoize"
    # Join order
    JOINORDER = "Leading"