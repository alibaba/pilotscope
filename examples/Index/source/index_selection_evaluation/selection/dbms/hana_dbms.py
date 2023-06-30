import json
import logging
import re
import subprocess
import time

import pyhdb

from selection.database_connector import DatabaseConnector


class HanaDatabaseConnector(DatabaseConnector):
    def __init__(self, db_name, autocommit=False):
        DatabaseConnector.__init__(self, db_name, autocommit=autocommit)
        self.db_system = "hana"
        self._connection = None

        # `db_name` is the schema name
        if not self.db_name:
            self.db_name = "SYSTEM"

        logging.getLogger(name="pyhdb").setLevel(logging.ERROR)
        self.read_connection_file()

        self.create_connection()
        self._alter_configuration()

        logging.debug("HANA connector created: {}".format(db_name))

    def read_connection_file(self):
        with open("database_connection.json", "r") as file:
            connection_data = json.load(file)
        self.host = connection_data["host"]
        self.port = connection_data["port"]
        self.db_user = connection_data["db_user"]
        self.db_user_password = connection_data["db_user_password"]
        self.import_directory = connection_data["import_directory"]
        self.ssh_user = connection_data["ssh_user"]

    def _alter_configuration(self):
        logging.info("Setting HANA variables")
        variables = [
            (
                "indexserver.ini",
                "SYSTEM",
                "datastatistics",
                "dev_force_use_non_runtime_datastatistics",
                "true",
            ),
            (
                "global.ini",
                "SYSTEM",
                "datastatistics",
                "dev_force_use_non_runtime_datastatistics",
                "true",
            ),
            (
                "indexserver.ini",
                "database",
                "import_export",
                "enable_csv_import_path_filter",
                "false",
            ),
        ]
        string = (
            "alter system alter configuration ('{}', '{}') "
            "set ('{}','{}')='{}' WITH RECONFIGURE"
        )

        for database_variable in variables:
            execute_string = string.format(*database_variable)
            logging.debug(execute_string)
            self.exec_only(execute_string)

    def create_connection(self):
        if self._connection:
            self.close()
        self._connection = pyhdb.connect(
            host=self.host,
            port=self.port,
            user=self.db_user,
            password=self.db_user_password,
        )
        self._connection.autocommit = self.autocommit
        self._cursor = self._connection.cursor()
        self.exec_only("set schema {}".format(self.db_name))

    def database_names(self):
        result = self.exec_fetch("select schema_name from schemas", False)
        return [x[0].lower() for x in result]

    def enable_simulation(self):
        create_schema = f"create schema {self.db_name}_empty"
        self.exec_only(create_schema)
        self.exec_only(f"set schema {self.db_name}_empty")
        self.create_tables()

    def update_query_text(self, text):
        # TODO 'tpch' / 'tpcds' custom rules
        text = text.replace(";\nlimit ", " limit ").replace("limit -1", "")
        text = self._replace_interval_by_function(text, "day")
        text = self._replace_interval_by_function(text, "month")
        text = self._replace_interval_by_function(text, "year")
        text = self._change_substring_syntax(text)
        return text

    def _replace_interval_by_function(self, text, token):
        text = re.sub(
            rf"date '(.+)' (.) interval '(.*)' {token}",
            rf"add_{token}s(to_date('\1','YYYY-MM-DD'),\2\3)",
            text,
        )
        return text

    def _change_substring_syntax(self, text):
        text = re.sub(
            r"substring\((.+) from (.+) for (.+)\)", r"substring(\1, \2, \3)", text
        )
        return text

    def create_database(self, database_name):
        self.exec_only("Create schema {}".format(database_name))
        logging.info("Database (schema) {} created".format(database_name))

    def import_data(self, table, path):
        scp_target = f"{self.ssh_user}@{self.host}:{self.import_directory}"
        # TODO pass scp output to logger
        subprocess.run(["scp", path, scp_target])
        csv_file = self.import_directory + "/" + path.split("/")[-1]
        import_statement = (
            f"import from csv file '{csv_file}' "
            f"into {table} with record delimited by '\\n' "
            "field delimited by '|'"
        )
        logging.debug("Import csv statement {}".format(table))
        self.exec_only(import_statement)

    def get_plan(self, query):
        query_text = self._prepare_query(query)
        statement_name = f"{self.db_name}_q{query.nr}"
        statement = (
            f"explain plan set " f"statement_name='{statement_name}' for " f"{query_text}"
        )
        try:
            self.exec_only(statement)
        except Exception as e:
            # pdb returns this even if the explain statement worked
            if str(e) != "Invalid or unsupported function code received: 7":
                raise e
        # TODO store result in dictionary-like format
        result = self.exec_fetch(
            "select operator_name, operator_details, "
            "output_size, subtree_cost, execution_engine "
            "from explain_plan_table "
            f"where statement_name='{statement_name}'",
            one=False,
        )
        self.exec_only(
            "delete from explain_plan_table where " f"statement_name='{statement_name}'"
        )
        self._cleanup_query(query)
        return result

    def _cleanup_query(self, query):
        for query_statement in query.text.split(";"):
            if "drop view" in query_statement:
                self.exec_only(query_statement)

    def get_cost(self, query):
        # TODO how to get cost when simulating indexes
        query_plan = self.get_plan(query)
        total_cost = query_plan[0][3]
        return total_cost

    def exec_query(self, query, timeout=None):
        query_text = self._prepare_query(query)
        start_time = time.time()
        self._cursor.execute(query_text)
        execution_time = time.time() - start_time
        self._cleanup_query(query)
        return execution_time, {}

    def drop_indexes(self):
        logging.info("Dropping indexes")
        statement = "select index_name from indexes where schema_name="
        statement += f"'{self.db_name.upper()}'"
        indexes = self.exec_fetch(statement, one=False)
        for index in indexes:
            index_name = index[0]
            drop_stmt = "drop index {}".format(index_name)
            logging.debug("Dropping index {}".format(index_name))
            self.exec_only(drop_stmt)

    def create_statistics(self):
        logging.info("HANA")

    def indexes_size(self):
        # TODO implement
        return 0

    def create_index(self, index):
        table_name = index.table()
        statement = (
            f"create index {index.index_idx()} "
            f"on {table_name} ({index.joined_column_names()})"
        )
        self.exec_only(statement)
        # TODO update index.estimated_size
