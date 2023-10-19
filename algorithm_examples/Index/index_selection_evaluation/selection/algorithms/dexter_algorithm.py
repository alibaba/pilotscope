import logging
import os
import subprocess

from selection.index import Index
from selection.selection_algorithm import SelectionAlgorithm

# Parameter is passed to dexter command line tool.
# min_saving_percentage: The mimimum percentage that an index candidate must reduce the
#                        cost of a query to be selected
DEFAULT_PARAMETERS = {"min_saving_percentage": 5}


# This algorithm implementation serves as an adapter for the Dexter index selection tool
# developed by Andrew Kane. The adapter calls the pre-installed tool.
# An introductory blog post can be found at:
# https://medium.com/@ankane/introducing-dexter-the-automatic-indexer-for-postgres-5f8fa8b28f27
# and the source code is published at: https://github.com/ankane/dexter/
class DexterAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters):
        SelectionAlgorithm.__init__(
            self, database_connector, parameters, DEFAULT_PARAMETERS
        )

    def _calculate_best_indexes(self, workload):
        min_percentage = self.parameters["min_saving_percentage"]
        database_name = self.database_connector.db_name

        index_columns = []

        for query in workload.queries:
            command = (
                f"dexter {database_name}"
                f' --min-cost-savings-pct {min_percentage} -s " '
            )
            # Prepare and cleaup query to create and drop view
            # (e.g. TPC-H query 15)
            # Commit because dexter tool creates another database connection
            command += self.database_connector._prepare_query(query)
            command += '"'
            self.database_connector.commit()
            p = subprocess.Popen(
                command,
                cwd=os.getcwd(),
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                shell=True,
            )
            with p.stdout:
                output_string = p.stdout.read().decode("utf-8")
            p.wait()
            self.database_connector._cleanup_query(query)
            self.database_connector.commit()

            log_output = output_string.replace("\n", "")
            logging.debug(f"{query}: {log_output}")

            if "public." in output_string:
                index = output_string.split("public.")[1].split(" (")
                table_name = index[0]
                column_names = index[1].split(")")[0].split(", ")
                columns = []
                for column_name in column_names:
                    column_object = next(
                        (
                            c
                            for c in query.columns
                            if c.name == column_name and c.table.name == table_name
                        ),
                        None,
                    )
                    columns.append(column_object)
                # Check if the same index columns already in list
                if columns not in index_columns:
                    index_columns.append(columns)
        return [Index(c) for c in index_columns]
