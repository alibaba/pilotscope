from typing import List

from sqlalchemy import Table, Column, select, func, text, inspect
from sqlalchemy.exc import OperationalError

from common.Index import Index
from DBController.BaseDBController import BaseDBController
from Exception.Exception import DBStatementTimeoutException
from PilotEnum import DatabaseEnum


class PostgreSQLController(BaseDBController):

    def __init__(self, config, echo=False, allow_to_create_db=False):
        super().__init__(config, echo, allow_to_create_db)

        self.simulate_index_controller = None

        self.engine = self.engine.execution_options(isolation_level="AUTOCOMMIT")
        self.connect()

    def _create_conn_str(self):
        # postgresql://postgres@localhost/stats
        return "{}://{}@{}/{}".format("postgresql", self.config.user, self.config.host, self.config.db)

    def execute(self, sql, fetch=False, conn=None):
        row = None
        try:
            result = self.connection.execute(text(sql) if isinstance(sql, str) else sql)
            if fetch:
                row = result.all()
        except OperationalError as e:
            if "canceling statement due to statement timeout" in str(e):
                raise DBStatementTimeoutException(str(e))
            else:
                raise e
        except Exception as e:
            if "PilotScopeFetchEnd" not in str(e):
                raise e
        return row

    def execute_batch(self, sqls, fetch=False):
        try:
            for sql in sqls[:-1]:
                print(sql)
                self.connection.execute(text(sql) if isinstance(sql, str) else sql)
            result = self.connection.execute(text(sqls[-1]) if isinstance(sqls[-1], str) else sqls[-1])
            if fetch:
                return result.all()
        except OperationalError as e:
            if "canceling statement due to statement timeout" in str(e):
                raise DBStatementTimeoutException(str(e))
            else:
                raise e
        except Exception as e:
            if "PilotScopeFetchEnd" not in str(e):
                raise e

    @staticmethod
    def get_hint_sql(key, value):
        return "SET {} TO {}".format(key, value)

    def create_table_if_absences(self, table_name, column_2_value, primary_key_column=None,
                                 enable_autoincrement_id_key=True):
        column_2_type = self._to_db_data_type(column_2_value)
        metadata_obj = self.metadata
        if not self.exist_table(table_name):
            columns = []
            for column, column_type in column_2_type.items():
                if column == primary_key_column:
                    columns.append(
                        Column(column, column_type, primary_key=True, autoincrement=enable_autoincrement_id_key))
                else:
                    columns.append(Column(column, column_type))
            table = Table(table_name, metadata_obj, *columns)
            table.create(self.engine)
            self.name_2_table[table_name] = table

    def insert(self, table_name, column_2_value: dict):
        table = self.name_2_table[table_name]
        self.execute(table.insert().values(column_2_value))

    def get_create_index_sql(self, index: Index):
        table_name = index.table
        return f"create index {index.get_index_name()} on {table_name} ({index.joined_column_names()})"

    def get_existed_index(self, table):
        inspector = inspect(self.engine)
        db_indexes = inspector.get_indexes(table)

        indexes = []
        for db_index in db_indexes:
            indexes.append(Index(columns=db_index["column_names"], table=table, index_name=db_index["name"]))
        return indexes

    def create_index(self, index: Index):
        self.execute(self.get_create_index_sql(index), fetch=False)

    def drop_index(self, index_name):
        statement = (
            f"DROP INDEX IF EXISTS {index_name}"
        )
        self.execute(statement, fetch=False)

    def drop_all_index(self, db_name):
        stmt = "select indexname from pg_indexes where schemaname='public'"
        indexes = self.execute(stmt, fetch=False)
        for index in indexes:
            index_name = index[0]
            self.drop_index(index_name)

    def get_index_number(self, table):
        inspector = inspect(self.engine)
        return len(inspector.get_indexes(table))

    def get_all_indexes_byte(self):
        # Returns size in bytes
        sql = ("select sum(pg_indexes_size(table_name::text)) from "
               "(select table_name from information_schema.tables "
               "where table_schema='public') as all_tables")
        result = self.execute(sql, fetch=True)
        return float(result[0][0])

    def get_table_indexes_byte(self, table):
        # Returns size in bytes
        sql = f"select pg_indexes_size('{table}');"
        result = self.execute(sql, fetch=True)
        return float(result[0][0])

    def get_index_byte(self, index_name):
        sql = f"select pg_table_size('{index_name}')"
        result = self.execute(sql, fetch=True)
        return float(result[0][0])

    def exist_table(self, table_name) -> bool:
        has_table = self.engine.dialect.has_table(self.engine.connect(), table_name)
        if has_table:
            return True
        return False

    def get_table_row_count(self, table_name):
        stmt = select(func.count()).select_from(self.name_2_table[table_name])
        result = self.execute(stmt, fetch=True)
        return result[0][0]

    def modify_sql_for_ignore_records(self, sql, is_execute):
        return self.get_explain_sql(sql, is_execute)

    def explain_physical_plan(self, sql, comment=""):
        return self._explain(sql, comment, False)

    def explain_execution_plan(self, sql, comment=""):
        return self._explain(sql, comment, True)

    def get_explain_sql(self, sql, execute: bool, comment=""):
        return "{} explain (ANALYZE {}, VERBOSE, SETTINGS, SUMMARY, FORMAT JSON) {}".format(comment,
                                                                                            "" if execute else "False",
                                                                                            sql)

    def _explain(self, sql, comment, execute: bool):
        try:
            return self.connection.execute(text(self.get_explain_sql(sql, execute, comment))).all()[0][0][0]
        except Exception as e:
            print(e)
            raise e


class SimulateIndexController:
    def create_index(self, index: Index):
        table_name = index.table()
        statement = (
            "select * from hypopg_create_index( "
            f"'create index on {table_name} "
            f"({index.joined_column_names()})')"
        )
        result = self.exec_fetch(statement)
        return result
