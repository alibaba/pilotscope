from pandas import DataFrame

from pandas import DataFrame
from sqlalchemy import Table, Column, Integer, MetaData, select, func, text

from DBController.BaseDBController import BaseDBController


class PostgreSQLController(BaseDBController):

    def __init__(self, config, echo=False, allow_to_create_db=False):
        super().__init__(config, echo, allow_to_create_db)

    def _create_conn_str(self):
        # postgresql://postgres@localhost/stats
        return "{}://{}@{}/{}".format("postgresql", self.config.user, self.config.host, self.config.db)

    def execute(self, sql, fetch=False):
        row = None
        with self.engine.connect() as conn:
            result = conn.execute(text(sql) if isinstance(sql, str) else sql)
            if fetch:
                row = result.fetchall()
            conn.commit()
        return row

    def get_hint_sql(self, key, value):
        raise RuntimeError

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
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(self.get_explain_sql(sql, execute, comment))
            result = cursor.fetchall()
            return result[0][0][0]
        finally:
            conn.close()

        # def database_name(self):
    #     return self.conn_str.split('/')[-1]

    # def database_names(self):
    #     result = self.exec_fetch("select datname from pg_database", False)
    #     return [x[0] for x in result]

    # def create_database(self, database_name):
    #     self.exec_only("create database {}".format(database_name))

    # def drop_database(self, database_name):
    #     statement = f"DROP DATABASE {database_name};"
    #     self.exec_only(statement)

    # def import_data(self, table, path, delimiter="|"):
    #     with open(path, "rb") as file:
    #         s = file.read().decode()
    #         fs = StringIO(s.encode("ascii", "ignore").decode("ascii"))
    #         self.cursor.copy_from(fs, table, sep=delimiter, null="")

    # def dump_data(self, table, path=".", delimiter=',', null=""):
    #     if (os.path.isdir(path)):
    #         path = os.path.join(path, f"{table}.csv")
    #     with open(path, "w") as file:
    #         self.cursor.copy_to(file, table, sep=delimiter, null=null)

    # def drop_index(self, index_name):
    #     statement = f"drop index {index_name}"
    #     self.exec_only(statement)

    # # give columns and table of a index, create it and return estimated size
    # def create_index(self, table_of_index, column_names):
    #     table_name = table_of_index
    #     columns = ",".join(column_names)
    #     index_idx = "{}_{}_idx".format(table_name, "_".join(column_names))
    #     statement = (f"create index {index_idx} "
    #                  f"on {table_name} ({columns})")
    #     # print(statement)
    #     self.exec_only(statement)
    #     size = self.exec_fetch(f"select relpages from pg_class c "
    #                            f"where c.relname = '{index_idx}'")
    #     size = size[0]
    #     return size * 8 * 1024

    # def drop_indexes(self):
    #     stmt = "select indexname from pg_indexes where schemaname='public'"
    #     indexes = self.exec_fetch(stmt, one=False)
    #     for index in indexes:
    #         index_name = index[0]
    #         if (index_name.startswith("pgsysml_")):
    #             continue
    #         drop_stmt = "drop index {}".format(index_name)
    #         print("Dropping index {}".format(index_name))
    #         self.exec_only(drop_stmt)

    # def table_names(self):
    #     stmt = "select table_name from information_schema.tables where table_schema='public'"
    #     return [x[0] for x in self.exec(stmt).all()]

    # def get_rows_of_table(self, table):
    #     return self.exec(f"select count(*) from {table}").all()[0][0]

    # def columns_of_table(self, table):
    #     return {
    #         row[0]: row[1]
    #         for row in self.exec(f"select column_name,data_type,identity_maximum from information_schema.columns where table_name='{table}'").all()
    #     }

    # def number_of_distinct_val(self, table, column):
    #     return self.exec(f"select count(distinct {column}) from {table};").all()[0][0]

    # def info_of_col(self, table, column, info):
    #     info_stmt = None
    #     if isinstance(info, str):
    #         info_stmt = f"{info}({column})"
    #     else:
    #         for x in info:
    #             if info_stmt == None:
    #                 info_stmt = f"{x}({column})"
    #             else:
    #                 info_stmt += f",{x}({column})"
    #     # print(f"select {info_stmt} from {table};")
    #     res = self.exec(f"select {info_stmt} from {table};").all()[0]
    #     return res

    # def indexes_size(self):
    #     # Returns size in bytes
    #     statement = ("select sum(pg_indexes_size(table_name::text)) from "
    #                  "(select table_name from information_schema.tables "
    #                  "where table_schema='public') as all_tables")
    #     result = self.exec_fetch(statement)
    #     return result[0]

    # def number_of_indexes(self):
    #     statement = """select count(*) from pg_indexes
    #                    where schemaname = 'public'"""
    #     result = self.exec_fetch(statement)
    #     return result[0]

    # def create_statistics(self):
    #     self.commit()
    #     self.exec_only("analyze")
    #     self.commit()

    # def set_random_seed(self, value=0):
    #     self.exec_only(f"SELECT setseed({value})")

    # # To support query with create view, create the view and return its query.
    # def _prepare_query(self, query):
    #     for query_statement in query.text.split(";"):
    #         if "create view" in query_statement:
    #             try:
    #                 self.exec_only(query_statement)
    #             except Exception as e:
    #                 print(e)
    #         elif "select" in query_statement or "SELECT" in query_statement:
    #             return query_statement

    # #Use it after _prepare_query, drop the view in query
    # def _cleanup_query(self, query):
    #     for query_statement in query.text.split(";"):
    #         if "drop view" in query_statement:
    #             self.exec_only(query_statement)
    #             self.commit()

    # # giving a query, run it and return total time and plan
    # # PostgreSQL expects the timeout in milliseconds
    # def exec_query(self, query, timeout=None):
    #     query_text = self._prepare_query(query)
    #     if timeout:
    #         set_timeout = f"set statement_timeout={timeout}"
    #         self.exec_only(set_timeout)
    #     statement = f"explain (analyze, buffers, format json) {query_text}"
    #     try:
    #         plan = self.exec_fetch(statement, one=True)[0][0]
    #         result = plan["Execution Time"] + plan["Planning Time"], plan["Plan"]
    #     except Exception as e:
    #         print(f"{query.nr}, {e}")
    #         self.connection.rollback()
    #         result = None, self.get_plan(query)
    #     # Disable timeout
    #     self.cursor.execute("set statement_timeout = 0")
    #     self._cleanup_query(query)
    #     return result

    # def get_cost(self, query):
    #     query_plan = self.get_plan(query)
    #     total_cost = query_plan["Total Cost"]
    #     return total_cost

    # def get_plan(self, query):
    #     query_text = self.prepare_query(query)
    #     statement = f"explain (format json) {query_text}"
    #     query_plan = self.exec_fetch(statement)[0][0]["Plan"]
    #     self._cleanup_query(query)
    #     return query_plan

    # def table_exists(self, table_name):
    #     statement = f"""SELECT EXISTS (
    #         SELECT 1
    #         FROM pg_tables
    #         WHERE tablename = '{table_name}');"""
    #     result = self.exec_fetch(statement)
    #     return result[0]

    # def database_exists(self, database_name):
    #     statement = f"""SELECT EXISTS (
    #         SELECT 1
    #         FROM pg_database
    #         WHERE datname = '{database_name}');"""
    #     result = self.exec_fetch(statement)
    #     return result[0]

    # def execute(self, sqls) -> PilotTransData:
    #     pass

    # def get_set_hint_sql(self, key, value):
    #     return ""

    # # def backup_config(self, backup_path=None):
    # #     if (backup_path == None):
    # #         backup_path = self.backup_path
    # #     with open(self.config_path, "r") as fr:
    # #         config_file = fr.read()
    # #         with open(backup_path, "w") as fw:
    # #             fw.write(config_file)

    # # # recover postgresql.conf from file
    # # def recover_config(self, backup_path=None):
    # #     if (backup_path == None):
    # #         backup_path = self.backup_path
    # #     with open(backup_path, "r") as fr:
    # #         backup_file = fr.read()
    # #         with open(self.config_path, "w") as fw:
    # #             fw.write(backup_file)

    # # def write_knob_to_file(self, knobs):
    # #     with open(self.config_path, "w") as f:
    # #         f.write(self.config_file)
    # #         f.write("\n")
    # #         for k, v in knobs.items():
    # #             if k.startswith("pgsysml."):
    # #                 continue
    # #             f.write("{} = {}\n".format(k, v))

    # # def surun(self, cmd):
    # #     os.system("su {} -c '{}'".format(self.username, cmd))

    # # def start(self):
    # #     self.surun("{} start -D {}".format(self.pg_ctl, self.pgdata))

    # # def shutdown(self):
    # #     self.surun("{} stop -D {}".format(self.pg_ctl, self.pgdata))

    # # def status(self):
    # #     res = os.popen("su {} -c '{} status -D {}'".format(self.username, self.pg_ctl, self.pgdata))
    # #     return res.read()
