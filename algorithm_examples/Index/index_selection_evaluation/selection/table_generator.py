import logging
import os
import platform
import re
import subprocess

from selection.utils import b_to_mb
from selection.workload import Column, Table


class TableGenerator:
    def __init__(
        self,
        benchmark_name,
        scale_factor,
        database_connector,
        explicit_database_name=None,
    ):
        self.scale_factor = scale_factor
        self.benchmark_name = benchmark_name
        self.db_connector = database_connector
        self.explicit_database_name = explicit_database_name

        self.database_names = self.db_connector.database_names()
        self.tables = []
        self.columns = []
        self._prepare()
        if self.database_name() not in self.database_names:
            self._generate()
            self.create_database()
        else:
            logging.debug("Database with given scale factor already " "existing")
        self._read_column_names()

    def database_name(self):
        if self.explicit_database_name:
            return self.explicit_database_name

        name = "indexselection_" + self.benchmark_name + "___"
        name += str(self.scale_factor).replace(".", "_")
        return name

    def _read_column_names(self):
        # Read table and column names from 'create table' statements
        filename = self.directory + "/" + self.create_table_statements_file
        with open(filename, "r") as file:
            data = file.read().lower()
        create_tables = data.split("create table ")[1:]
        for create_table in create_tables:
            splitted = create_table.split("(", 1)
            table = Table(splitted[0].strip())
            self.tables.append(table)
            # TODO regex split? ,[whitespace]\n
            for column in splitted[1].split(",\n"):
                name = column.lstrip().split(" ", 1)[0]
                if name == "primary":
                    continue
                column_object = Column(name)
                table.add_column(column_object)
                self.columns.append(column_object)

    def _generate(self):
        logging.info("Generating {} data".format(self.benchmark_name))
        logging.info("scale factor: {}".format(self.scale_factor))
        self._run_make()
        self._run_command(self.cmd)
        if self.benchmark_name == "tpcds":
            self._run_command(["bash", "../../scripts/replace_in_dat.sh"])
        logging.info("[Generate command] " + " ".join(self.cmd))
        self._table_files()
        logging.info("Files generated: {}".format(self.table_files))

    def create_database(self):
        self.db_connector.create_database(self.database_name())
        filename = self.directory + "/" + self.create_table_statements_file
        with open(filename, "r") as file:
            create_statements = file.read()
        # Do not create primary keys
        create_statements = re.sub(r",\s*primary key (.*)", "", create_statements)
        self.db_connector.db_name = self.database_name()
        self.db_connector.create_connection()
        self.create_tables(create_statements)
        self._load_table_data(self.db_connector)
        self.db_connector.enable_simulation()

    def create_tables(self, create_statements):
        logging.info("Creating tables")
        for create_statement in create_statements.split(";")[:-1]:
            self.db_connector.exec_only(create_statement)
        self.db_connector.commit()

    def _load_table_data(self, database_connector):
        logging.info("Loading data into the tables")
        for filename in self.table_files:
            logging.debug("    Loading file {}".format(filename))

            table = filename.replace(".tbl", "").replace(".dat", "")
            path = self.directory + "/" + filename
            size = os.path.getsize(path)
            size_string = f"{b_to_mb(size):,.4f} MB"
            logging.debug(f"    Import data of size {size_string}")
            database_connector.import_data(table, path)
            os.remove(os.path.join(self.directory, filename))
        database_connector.commit()

    def _run_make(self):
        if "dbgen" not in self._files() and "dsdgen" not in self._files():
            logging.info("Running make in {}".format(self.directory))
            self._run_command(self.make_command)
        else:
            logging.info("No need to run make")

    def _table_files(self):
        self.table_files = [x for x in self._files() if ".tbl" in x or ".dat" in x]

    def _run_command(self, command):
        cmd_out = "[SUBPROCESS OUTPUT] "
        p = subprocess.Popen(
            command,
            cwd=self.directory,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        with p.stdout:
            for line in p.stdout:
                logging.info(cmd_out + line.decode("utf-8").replace("\n", ""))
        p.wait()

    def _files(self):
        return os.listdir(self.directory)

    def _prepare(self):
        if self.benchmark_name == "tpch":
            self.make_command = ["make", "DATABASE=POSTGRESQL"]
            if platform.system() == "Darwin":
                self.make_command.append("MACHINE=MACOS")

            self.directory = "./tpch-kit/dbgen"
            self.create_table_statements_file = "dss.ddl"
            self.cmd = ["./dbgen", "-s", str(self.scale_factor), "-f"]
        elif self.benchmark_name == "tpcds":
            self.make_command = ["make"]
            if platform.system() == "Darwin":
                self.make_command.append("OS=MACOS")

            self.directory = "./tpcds-kit/tools"
            self.create_table_statements_file = "tpcds.sql"
            self.cmd = ["./dsdgen", "-SCALE", str(self.scale_factor), "-FORCE"]

            # 0.001 is allowed for testing
            if (
                int(self.scale_factor) - self.scale_factor != 0
                and self.scale_factor != 0.001
            ):
                raise Exception("Wrong TPCDS scale factor")
        else:
            raise NotImplementedError("only tpch/ds implemented.")
