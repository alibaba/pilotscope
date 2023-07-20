import os
import logging
from typing_extensions import deprecated
from common.Util import pilotscope_exit
from DBController.BaseDBController import BaseDBController
from Exception.Exception import DBStatementTimeoutException
from components.PilotConfig import PilotConfig, SparkConfig
from components.PilotEnum import PilotEnum
from PilotEnum import DataFetchMethodEnum, DatabaseEnum, TrainSwitchMode
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql import DataFrame
from typing import Union, Dict, Tuple
import pandas
import json
import re
import threading
import numpy as np

logging.getLogger('pyspark').setLevel(logging.ERROR)
logging.getLogger("py4j").setLevel(logging.ERROR)
logger = logging.getLogger("PilotScope")

SUCCESS = 1
FAILURE = 0


class SparkSQLTypeEnum(PilotEnum):
    String = StringType
    Integer = IntegerType
    Float = FloatType


class SparkSQLDataSourceEnum(PilotEnum):
    CSV = "csv"
    JSON = "json"
    PARQUET = "parquet"
    HIVE = "hive"
    POSTGRESQL = "postgresql"


class SparkIOWriteModeEnum(PilotEnum):
    OVERWRITE = "overwrite"
    APPEND = "append"
    ERROR_IF_EXISTS = "errorifexists"
    IGNORE = "ignore"


"""
class SparkConfig(PilotConfig):
    def __init__(self, app_name, master_url,
                 datasource_type, datasource_conn_info,
                 db_config_path="./pilotscope_spark_sql_config.txt",
                 backup_db_config_path="./pilotscope_spark_sql_config.backup.txt",
                 other_configs=None) -> None:
        super().__init__()
        self.appName = app_name
        self.master = master_url
        self.datasource_type = datasource_type
        self.datasource_conn_info = datasource_conn_info
        self.db_config_path = db_config_path
        self.backup_db_config_path = backup_db_config_path
        self.configs = {}
        if other_configs is not None:
            for config_name in other_configs:
                self.configs[config_name] = other_configs[config_name]
        self.db_type = DatabaseEnum.SPARK
"""


def sparkSessionFromConfig(spark_config: SparkConfig):
    session = SparkSession.builder \
        .appName(spark_config.app_name) \
        .master(spark_config.master_url)
    for config_name in spark_config.spark_configs:
        session = session.config(config_name, spark_config.spark_configs[config_name])
    if spark_config.datasource_type == SparkSQLDataSourceEnum.POSTGRESQL:
        session = session.config("spark.jars.packages", spark_config.jdbc)
    return session.getOrCreate()


# class SparkConnection:
#    def __init__(self, config: SparkConfig):
#        self.config = config
#        self._conn = None

#    def create(self):
#        self._conn = sparkSessionFromConfig(self.config)

#    def close(self):
#        self._conn = None

class SparkColumn(StructField):
    def __init__(self, column_name, column_type: SparkSQLTypeEnum):
        # Spark does not support primary key and auto-increment
        super().__init__(column_name, column_type())


class SparkTable:
    def __init__(self, table_name, metadata, *columns):
        self.table_name = table_name
        self.columns = list(columns)
        self.schema = StructType(list(columns))
        self.df: DataFrame = None

    def load(self, engine, analyze=True):
        self.df = engine.io.read(self.table_name)
        self.df.createOrReplaceTempView(self.table_name)
        self.schema = self.df.schema
        if analyze:
            self.analyzeStats(engine)

    def create(self, engine, analyze=True):
        if engine.has_table(engine.session, self.table_name, where="datasource"):
            # Table exists in the data source, load it directly
            # self.df = engine.io.read(self.table_name)
            self.load(engine, analyze)
        else:
            if engine.has_table(engine.session, self.table_name, where="session"):
                # Table exists in the current session. 
                # To avoid duplicated tables in the same session, an error will be thrown here.
                raise RuntimeError("Duplicated table cannot be created in the current session.")
            else:
                # No such a table in the data source as well as in the session, 
                # so create an empty table and persist it to the data source.
                self.df = engine.session.createDataFrame(data=[], schema=self.schema)
                # engine.io.write(self.df, mode=SparkIOWriteModeEnum.OVERWRITE, target_table_name=self.table_name)
            self.df.createOrReplaceTempView(self.table_name)
            if analyze:
                self.analyzeStats(engine)
        # engine.session.catalog.cacheTable(self.table_name)
        # if analyze:
        #    engine.session.sql("ANALYZE TABLE {} COMPUTE STATISTICS FOR ALL COLUMNS".format(self.table_name))

    # get the SQL string for insertion
    def insert(self, engine, column_2_value, analyze=False, persist=True):
        column_names = list(column_2_value.keys())
        new_row = engine.session.createDataFrame([tuple(column_2_value[col] for col in column_names)], column_names)
        self.df = self.df.union(new_row)
        self.df.createOrReplaceTempView(self.table_name)
        if analyze:
            self.analyzeStats(engine)
        if persist:
            engine.io.write(new_row, mode=SparkIOWriteModeEnum.APPEND, target_table_name=self.table_name)

    def nrows(self):
        return self.df.count()

    def cache(self, engine):
        engine.session.catalog.cacheTable(self.table_name)

    def analyzeStats(self, engine):
        self.cache(engine)
        engine.session.sql("ANALYZE TABLE {} COMPUTE STATISTICS FOR ALL COLUMNS".format(self.table_name))

    def persist(self, engine):
        engine.io.write(self, mode=SparkIOWriteModeEnum.OVERWRITE)

    def clear_rows(self, engine, persist=False):
        self.df = engine.session.createDataFrame(data=[], schema=self.schema)
        self.df.createOrReplaceTempView(self.table_name)
        self.analyzeStats(engine)
        if persist:
            self.persist(engine)

class SparkIO:
    def __init__(self, datasource_type: SparkSQLDataSourceEnum, engine, **datasource_conn_info) -> None:
        self.reader = None
        self.conn_info = datasource_conn_info
        self.datasource_type = datasource_type
        if datasource_type != SparkSQLDataSourceEnum.POSTGRESQL:
            raise RuntimeError("SparkIO has not been tested on any other data source types than 'postgresql'.")
        if datasource_type == SparkSQLDataSourceEnum.POSTGRESQL:
            self.reader = engine.session.read \
                .format("jdbc") \
                .option("driver", "org.postgresql.Driver") \
                .option("url", "jdbc:postgresql://{}/{}".format(self.conn_info['host'], self.conn_info['db'])) \
                .option("user", self.conn_info['user']) \
                .option("password", self.conn_info['pwd'])

    def read(self, table_name=None, query=None) -> DataFrame:
        assert not (table_name is not None and query is not None)
        assert not (table_name is None and query is None)
        if table_name is not None:
            self.reader = self.reader.option("dbtable", table_name)
        elif query is not None:
            self.reader = self.reader.option("query", query)
        return self.reader.load()

    def write(self, table_or_rows: Union[SparkTable, DataFrame], mode: SparkIOWriteModeEnum, target_table_name=None):
        if isinstance(table_or_rows, SparkTable):
            df = table_or_rows.df
        else:
            df = table_or_rows
        if target_table_name is None and not isinstance(table_or_rows, SparkTable):
            raise Exception("Target table name not specified.")
        else:
            if target_table_name is not None:
                table_name = target_table_name
            elif isinstance(table_or_rows, SparkTable):
                table_name = table_or_rows.table_name
        if self.datasource_type == SparkSQLDataSourceEnum.POSTGRESQL:
            write = df.write \
                .mode(mode.value) \
                .format("jdbc") \
                .option("driver", "org.postgresql.Driver") \
                .option("url", "jdbc:postgresql://{}/{}".format(self.conn_info['host'], self.conn_info['db'])) \
                .option("user", self.conn_info['user']) \
                .option("password", self.conn_info['pwd']) \
                .option("dbtable", table_name)
        write.save()

    def has_table(self, table_name):
        return self.read(table_name="information_schema.tables") \
            .filter("table_name = '{}'".format(table_name)) \
            .count() > 0

    def get_all_table_names_in_datasource(self) -> np.ndarray:
        return self.read(table_name="information_schema.tables") \
            .filter("table_schema != 'pg_catalog'") \
            .filter("table_schema != 'information_schema'").toPandas()["table_name"].values


class SparkEngine:
    def __init__(self, config: SparkConfig):
        self.config = config
        self.session = None
        self.io = None

    def connect(self):
        self.session = sparkSessionFromConfig(self.config)
        self.io = SparkIO(self.config.datasource_type, self, host=self.config.host, db=self.config.db,
                          user=self.config.user, pwd=self.config.pwd)
        return self.session

    def _has_table_in_datasource(self, table_name):
        return self.io.has_table(table_name)

    def _has_table_in_session(self, session, table_name):
        return session.catalog.tableExists(table_name)

    def has_table(self, connection: SparkSession, table_name: str, where="datasource") -> bool:
        if where == "datasource":
            return self._has_table_in_datasource(table_name)
        elif where == "session":
            return self._has_table_in_session(connection, table_name)
        else:
            raise ValueError("Unsupport 'where' value: {}".format(where))

    def get_all_table_names_in_datasource(self) -> np.ndarray:
        return self.io.get_all_table_names_in_datasource()

    # def clearCachedTables(self):
    #    self.session.catalog.clearCache()


class SparkSQLController(BaseDBController):

    # instances = set()

    # def __new__(cls, *args, **kwargs):
    #    instance = super().__new__(cls)
    #    cls.instances.add(instance)
    #    return instance

    # def __del__(self):
    #    type(self).instances.remove(self)

    def __init__(self, config: SparkConfig, echo=False, allow_to_create_db=False):
        super().__init__(config, echo, allow_to_create_db)

    def _db_init(self):
        self.name_2_table = {}
        self.engine: SparkEngine = self._create_engine()
        self.connect_if_loss()

    def _create_conn_str(self):
        return ""

    def _create_engine(self):
        return SparkEngine(self.config)

    def _to_db_data_type(self, column_2_value):
        column_2_type = {}
        for col, data in column_2_value.items():
            data_type = SparkSQLTypeEnum.String
            if type(data) == int:
                data_type = SparkSQLTypeEnum.Integer
            elif type(data) == float:
                data_type = SparkSQLTypeEnum.Float
            elif type(data) == str:
                data_type = SparkSQLTypeEnum.String
            elif type(data) == dict:
                data_type = SparkSQLTypeEnum.String
            elif type(data) == list:
                data_type = SparkSQLTypeEnum.String
            column_2_type[col] = data_type.value
        return column_2_type

    def load_all_tables_from_datasource(self):
        all_user_created_table_names = self.engine.get_all_table_names_in_datasource()
        for table_name in all_user_created_table_names:
            self.load_table_if_exists_in_datasource(table_name)

    def connect_if_loss(self):
        if not self.is_connect():
            self.connection_thread.conn = self.engine.connect()
            all_user_created_table_names = self.engine.get_all_table_names_in_datasource()
            for table_name in all_user_created_table_names:
                self.load_table_if_exists_in_datasource(table_name)
                logger.debug("[connect_if_loss] Loaded table '{}'".format(table_name))
        pass

    def disconnect(self):
        if self.get_connection() is not None:
            # try:
            self.persist_tables()
            self.engine.clearCachedTables()
            self.connection_thread.conn.stop()
            self.connection_thread.conn = None
            # except: # deal with connection already stopped
            #    pass

    def persist_table(self, table_name):
        self.name_2_table[table_name].persist(self.engine)

    def persist_tables(self):
        for table in self.name_2_table.values():
            table.persist(self.engine)

    def exist_table(self, table_name, where="session") -> bool:
        has_table = self.engine.has_table(self.get_connection(), table_name, where)
        if has_table:
            return True
        return False

    def load_table_if_exists_in_datasource(self, table_name):
        if (not self.exist_table(table_name, where="session")) and self.exist_table(table_name, where="datasource"):
            # If the table exists in the data source but not in the current session, 
            #   then the table will be loaded from the data source.

            # logger.debug(
            #    "[create_table_if_absences] Table '{}' exists in the data source but not in the current session, ".format(
            #        table_name) +
            #    "so it will be loaded from the data source and your input schema will be ignored.")

            table = SparkTable(table_name, None)
            table.load(self.engine)
            self.name_2_table[table_name] = table

    # collect statistics for the given table
    def analyze_table_stats(self, table_name):
        self.load_table_if_exists_in_datasource(table_name)
        self.name_2_table[table_name].analyzeStats(self.engine)

    def analyze_all_table_stats(self):
        for table in self.name_2_table.values():
            table.analyzeStats(self.engine)

    # clear all SparkTable instances in cache 
    def clear_all_tables(self):
        conn = self.get_connection()
        conn.catalog.clearCache()
        for table_name in self.name_2_table:
            conn.catalog.dropTempView(table_name)
        self.name_2_table.clear()

    # check whether the input key (config name) is modifiable in runtime
    # and set its value to the given value if it is modifiable
    def set_hint(self, key, value):
        if self.get_connection().conf.isModifiable(key):
            # self.connection.conf.set(key, value)
            sql = "SET {} = {}".format(key, value)
            self.execute(sql)
        else:
            logger.warning(
                "[get_hint_sql] Configuration '{}' is not modifiable in runtime, nothing changed".format(key))

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        self.connect_if_loss()
        if primary_key_column is not None:
            logger.warning(
                "[create_table_if_absences] Spark SQL does not support specifying primary key while creating table.")
            primary_key_column = None
        column_2_type = self._to_db_data_type(column_2_value)
        # metadata_obj = self.metadata
        if not self.exist_table(table_name, where="session"):
            # Only checks whether the table exists in current session.
            # If the table exists in the data source but not in the session, 
            #   here self.exist_table simply returns False, 
            #   then table.create will load it from the data source.
            if self.exist_table(table_name, where="datasource"):
                logger.warning(
                    "[create_table_if_absences] Table '{}' exists in the data source but not in the current session, ".format(
                        table_name) +
                    "so it will be loaded from the data source and your input schema will be ignored.")
            columns = []
            for column, column_type in column_2_type.items():
                columns.append(SparkColumn(column, column_type))
            table = SparkTable(table_name, None, *columns)
            table.create(self.engine)
            self.name_2_table[table_name] = table
        else:
            logger.warning("[create_table_if_absences] Table '{}' exists, nothing changed.".format(table_name))

    def get_table_row_count(self, table_name):
        self.load_table_if_exists_in_datasource(table_name)
        if table_name not in self.name_2_table:
            raise RuntimeError(
                "The table '{}' not found in both current session and the data source.".format(table_name))
        return self.name_2_table[table_name].nrows()

    def insert(self, table_name, column_2_value: dict, persist=True):
        self.load_table_if_exists_in_datasource(table_name)
        table = self.name_2_table[table_name]
        table.insert(self.engine, column_2_value, persist=persist)

    def execute(self, sql, fetch=False) -> Union[pandas.DataFrame, DataFrame]:
        row = None
        try:
            df = self.get_connection().sql(sql)
            row = df.toPandas()
            if not fetch:
                row = df
        except Exception as e:
            if "PilotScopeFetchEnd" not in str(e):
                raise e
        return row

    def _unresolvedLogicalPlan(self, query_execution):
        return query_execution.logical()

    def _resolvedLogicalPlan(self, query_execution):
        return query_execution.analyzed()

    def _optimizedLogicalPlan(self, query_execution):
        return query_execution.optimizedPlan()

    def _logicalPlan(self, query_execution):
        return self._optimizedLogicalPlan(query_execution)

    def _physicalPlan(self, query_execution):
        return query_execution.executedPlan()

    def explain_logical_plan(self, sql, comment="") -> Dict:
        sql = "{} {}".format(comment, sql)
        plan = self._logicalPlan(self.execute(sql)._jdf.queryExecution())
        return json.loads(plan.toJSON())

    def explain_physical_plan(self, sql, comment="") -> Dict:
        sql = "{} {}".format(comment, sql)
        plan = self._physicalPlan(self.execute(sql)._jdf.queryExecution())
        return json.loads(plan.toJSON())[0]

    def get_estimated_cost(self, sql) -> Tuple[int]:
        raise NotImplementedError("Spark SQL does not support cost estimation.You can use row count or sizeByte instead.")
        plan = self._logicalPlan(self.execute(sql)._jdf.queryExecution())
        cost_str = plan.stats().simpleString()
        pattern = re.compile(r"sizeInBytes=([0-9.]+) B, rowCount=([0-9]+)")
        res = pattern.search(cost_str)
        return res.groups()[0], res.groups()[1]


    # done
    def write_knob_to_file(self, knobs):
        for k, v in knobs.items():
            self.set_hint(k, v)

    # done
    def recover_config(self):
        # reset all modifiable runtime configurations
        self.get_connection().sql("RESET")

    # switch user and run
    def _surun(self, cmd):
        # os.system("su {} -c '{}'".format(self.config.user, cmd))
        pass

    def shutdown(self):
        # self._surun("{} stop -D {}".format(self.config.pg_ctl, self.config.pgdata))
        pass

    def start(self):
        # self._surun("{} start -D {}".format(self.config.pg_ctl, self.config.pgdata))
        # for instance in type(self).instances:
        #    instance.connect()
        pass

    def explain_execution_plan(self, sql, comment=""):
        # return self._explain(sql, comment, True)
        pass

    def get_explain_sql(self, sql, execute: bool, comment=""):
        # return "{} explain (ANALYZE {}, VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
        #                                                                                    "" if execute else "False",
        #                                                                                    sql)
        pass

    def modify_sql_for_ignore_records(self, sql, is_execute):
        # return self.get_explain_sql(sql, is_execute)
        pass

    def status(self):
        # res = os.popen("su {} -c '{} status -D {}'".format(self.config.user,self.config.pg_ctl, self.config.pgdata))
        # return res.read()
        pass

    def get_buffercache(self):
        pass

    # NOTE: modified from DBTune (MIT liscense)
    def get_internal_metrics(self):
        pass

    def execute_batch(self, sql, fetch=False):
        pass

    def create_index(self, index_name, table, columns):
        pass

    def create_index(self, index):
        pass

    def drop_index(self, index_name):
        pass

    def drop_all_indexes(self):
        pass

    def get_all_indexes_byte(self):
        pass

    def get_table_indexes_byte(self, table):
        pass

    def get_index_byte(self, index_name):
        pass
