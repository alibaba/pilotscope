import json
import logging
from typing import Union, Dict, Tuple

import numpy as np
import pandas
from pyspark.sql import DataFrame
from pyspark.sql import SparkSession
from pyspark.sql.types import *

from pilotscope.Common.Index import Index
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Exception.Exception import PilotScopeNotSupportedOperationException
from pilotscope.PilotConfig import SparkConfig, PostgreSQLConfig
from pilotscope.PilotEnum import PilotEnum, SparkSQLDataSourceEnum

logging.getLogger('pyspark').setLevel(logging.ERROR)
logging.getLogger("py4j").setLevel(logging.ERROR)
logger = logging.getLogger("PilotScope")

SUCCESS = 1
FAILURE = 0


class SparkSQLTypeEnum(PilotEnum):
    String = StringType
    Integer = IntegerType
    Float = FloatType


class SparkIOWriteModeEnum(PilotEnum):
    OVERWRITE = "overwrite"
    APPEND = "append"
    ERROR_IF_EXISTS = "errorifexists"
    IGNORE = "ignore"


def sparkSessionFromConfig(spark_config: SparkConfig):
    session = SparkSession.builder \
        .appName(spark_config.app_name) \
        .master(spark_config.master_url)
    for config_name in spark_config.spark_configs:
        session = session.config(config_name, spark_config.spark_configs[config_name])
    if spark_config.datasource_type == SparkSQLDataSourceEnum.POSTGRESQL:
        session = session.config("spark.jars.packages", spark_config.jdbc)
    return session.getOrCreate()


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

    def load(self, engine, analyze=False):
        self.df = engine.io.read(self.table_name)
        self.df.createOrReplaceTempView(self.table_name)
        self.schema = self.df.schema
        if analyze:
            self.analyzeStats(engine)

    def create(self, engine, analyze=False):
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
            self.persist(
                engine)  # persist self.df, now self.df is the table after inserting, so overwriting the whole table is right

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
            pg_config = PostgreSQLConfig("", self.conn_info["host"], self.conn_info["port"], self.conn_info["user"],\
                                         self.conn_info["pwd"], self.conn_info["db"])
            pg_controller = PostgreSQLController(pg_config, False) # to create database if self.conn_info["db"] do not exist in data source
            del pg_controller
            self.reader = engine.session.read \
                .format("jdbc") \
                .option("driver", "org.postgresql.Driver") \
                .option("url", "jdbc:postgresql://{}:{}/{}".format(self.conn_info['host'], self.conn_info["port"],
                                                                   self.conn_info['db'])) \
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
            df.cache()
            rows = df.count()  # do not delete this read operation of df, which make it possible to overwrite tables.
            write = df.write \
                .mode(mode.value) \
                .format("jdbc") \
                .option("driver", "org.postgresql.Driver") \
                .option("url", "jdbc:postgresql://{}:{}/{}".format(self.conn_info['host'], self.conn_info["port"],
                                                                   self.conn_info['db'])) \
                .option("user", self.conn_info['user']) \
                .option("password", self.conn_info['pwd']) \
                .option("dbtable", table_name)
            write.save()
            assert rows == df.count()

    def has_table(self, table_name):
        return self.read(table_name="information_schema.tables") \
                   .filter("table_name = '{}'".format(table_name)) \
                   .count() > 0

    def get_all_table_names_in_datasource(self) -> np.ndarray:
        return self.read(table_name="information_schema.tables") \
            .filter("table_schema == 'public'") \
            .filter("table_type == 'BASE TABLE'").toPandas()["table_name"].values


class SparkEngine:
    def __init__(self, config: SparkConfig):
        self.config = config
        self.session = None
        self.io = None

    def connect(self):
        self.session = sparkSessionFromConfig(self.config)
        self.io = SparkIO(self.config.datasource_type, self, host=self.config.db_host, port=self.config.db_port,
                          db=self.config.db,
                          user=self.config.db_user, pwd=self.config.db_user_pwd)
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

    def __init__(self, config: SparkConfig, echo=False):
        super().__init__(config, echo)

    def _db_init(self):
        self.name_2_table = {}
        self.engine: SparkEngine = self._create_engine()
        self._connect_if_loss()

    def _create_conn_str(self):
        return ""

    def _create_engine(self):
        return SparkEngine(self.config)

    def load_all_tables_from_datasource(self):
        all_user_created_table_names = self.engine.get_all_table_names_in_datasource()
        for table_name in all_user_created_table_names:
            self.load_table_if_exists_in_datasource(table_name)

    def _connect_if_loss(self):
        if not self._is_connect():
            self.connection_thread.conn = self.engine.connect()
            all_user_created_table_names = self.engine.get_all_table_names_in_datasource()
            for table_name in all_user_created_table_names:
                self.load_table_if_exists_in_datasource(table_name)
                logger.debug("[connect_if_loss] Loaded table '{}'".format(table_name))
        pass

    def _disconnect(self):
        if self._get_connection() is not None:
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
        has_table = self.engine.has_table(self._get_connection(), table_name, where)
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
        conn = self._get_connection()
        conn.catalog.clearCache()
        for table_name in self.name_2_table:
            conn.catalog.dropTempView(table_name)
        self.name_2_table.clear()

    # check whether the input key (config name) is modifiable in runtime
    # and set its value to the given value if it is modifiable
    def set_hint(self, key, value):
        if self._get_connection().conf.isModifiable(key):
            # self.connection.conf.set(key, value)
            sql = "SET {} = {}".format(key, value)
            self.execute(sql)
        else:
            logger.warning(
                "[get_hint_sql] Configuration '{}' is not modifiable in runtime, nothing changed".format(key))

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        self._connect_if_loss()
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

    def execute(self, sql, fetch=False, fetch_column_name=False) -> Union[pandas.DataFrame, DataFrame]:
        row = None
        try:
            self._connect_if_loss()
            df = self._get_connection().sql(sql)
            row = df.toPandas()
            if not fetch:
                row = df
        except Exception as e:
            if "PilotScopePullEnd" not in str(e):
                raise e
        return row

    def _unresolvedLogicalPlan(self, query_execution):
        return query_execution.logical()

    def _resolvedLogicalPlan(self, query_execution):
        return query_execution.spark_analyzed()

    def _optimizedLogicalPlan(self, query_execution):
        return query_execution.optimizedPlan()

    def _logicalPlan(self, query_execution):
        return self._optimizedLogicalPlan(query_execution)

    def _physicalPlan(self, query_execution):
        return query_execution.executedPlan()

    def explain_physical_plan(self, sql, comment="") -> Dict:
        sql = "{} {}".format(comment, sql)
        plan = self._physicalPlan(self.execute(sql)._jdf.queryExecution())
        return json.loads(plan.toJSON())[0]

    def get_estimated_cost(self, sql, comment="") -> Tuple[int]:
        raise PilotScopeNotSupportedOperationException(
            "Spark SQL does not support cost estimation.You can use row count or sizeByte instead.")

    def write_knob_to_file(self, key_2_value_knob):
        for k, v in key_2_value_knob.items():
            self.set_hint(k, v)

    def recover_config(self):
        # reset all modifiable runtime configurations
        self._get_connection().sql("RESET")

    def shutdown(self):
        pass

    def start(self):
        pass

    def explain_execution_plan(self, sql, comment=""):
        raise NotImplementedError

    def status(self):
        raise PilotScopeNotSupportedOperationException

    def get_buffercache(self):
        raise PilotScopeNotSupportedOperationException

    def create_index(self, index_name, table, columns):
        raise PilotScopeNotSupportedOperationException

    def create_index(self, index):
        raise PilotScopeNotSupportedOperationException

    def drop_index(self, index):
        raise PilotScopeNotSupportedOperationException

    def drop_all_indexes(self):
        raise PilotScopeNotSupportedOperationException

    def get_all_indexes_byte(self):
        raise PilotScopeNotSupportedOperationException

    def get_table_indexes_byte(self, table_name):
        raise PilotScopeNotSupportedOperationException

    def get_index_byte(self, index: Index):
        raise PilotScopeNotSupportedOperationException

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
