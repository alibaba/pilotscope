import itertools
import json
import logging
import os
import sys
import time
from typing import Dict, List, Set

from selection.index import Index
from selection.selection_algorithm import SelectionAlgorithm
from selection.workload import Workload

# The maximum width of index candidates and the number of applicable indexes
#   per query can be specified
DEFAULT_PARAMETERS = {
    "max_index_width": 1,
    "max_indexes_per_query": 1,
    "enumeration": "query-based",
    "output_folder": "benchmark_results/cophy",
    "overwrite": True,
}


class CoPhyInputGeneration(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(
            self, database_connector, parameters, DEFAULT_PARAMETERS
        )
        self.query_costs_without_indexes = {}

    def init_query_costs_without_indexes(self, workload):
        for query in workload.queries:
            self.query_costs_without_indexes[query] = self.cost_evaluation.calculate_cost(
                Workload([query]), set()
            )

    def full_enumeration(self, workload):
        logging.info("Full enumeration of index combinations")
        # generate all indexes and combinations based on all accessed attributes

        accessed_columns_per_table = {}
        # Identify accessed columns per table (over all included queries),
        #   which are used to generate wider (multi-attribute) indexes next
        for query in workload.queries:
            for column in query.columns:
                if column.table not in accessed_columns_per_table:
                    accessed_columns_per_table[column.table] = set()
                accessed_columns_per_table[column.table].add(column)

        candidate_indexes = set()
        # Generate wider indexes per table
        for number_of_index_columns in range(1, self.parameters["max_index_width"] + 1):
            for table in accessed_columns_per_table:
                for index_columns in itertools.permutations(
                    accessed_columns_per_table[table], number_of_index_columns
                ):
                    candidate_indexes.add(Index(index_columns))

        # stores indexes that have a benefit in any combination
        #   (to prune indexes with no benefit)
        useful_indexes: Set[Index] = set()
        query_costs_for_index_combination = {}

        for number_of_indexes_per_query in range(
            1, self.parameters["max_indexes_per_query"] + 1
        ):
            number_of_index_combinations = len(
                list(
                    itertools.combinations(candidate_indexes, number_of_indexes_per_query)
                )
            )
            logging.info(
                f"Evaluate {number_of_index_combinations} index combinations "
                f"with {number_of_indexes_per_query} indexes per query:"
            )
            i = 0
            for index_combination in itertools.combinations(
                candidate_indexes, number_of_indexes_per_query
            ):
                i += 1
                if i % 10000 == 0:
                    logging.info(f"  ... {i} / {number_of_index_combinations} done")
                is_useful_combination = False
                costs_per_query = {}
                for query in workload.queries:
                    query_cost = self.cost_evaluation.calculate_cost(
                        Workload([query]), set(index_combination), store_size=True
                    )
                    # test if query_cost is lower than default cost
                    if query_cost < self.query_costs_without_indexes[query]:
                        is_useful_combination = True
                        costs_per_query[query] = query_cost
                if is_useful_combination:
                    query_costs_for_index_combination[index_combination] = costs_per_query
                    for index in index_combination:
                        useful_indexes.add(index)
            logging.info(f"  ... {i} / {number_of_index_combinations} done")

        return useful_indexes, query_costs_for_index_combination

    def query_based_enumeration(self, workload):
        logging.info("Query-based enumeration of index combinations")
        # generate all indexes and combinations based on their appearance in queries

        index_combinations_for_workload = set()
        # Iterate over queries and build relevant index combinations
        for query in workload.queries:
            accessed_columns_per_table = {}
            # Identify accessed columns per table for a single query,
            #   which are used to generate wider (multi-attribute) indexes next
            for column in query.columns:
                if column.table not in accessed_columns_per_table:
                    accessed_columns_per_table[column.table] = set()
                accessed_columns_per_table[column.table].add(column)

            indexes_for_query = set()
            # Add single and multi-attribute indexes for the query
            for table in accessed_columns_per_table:
                for index_width in range(1, self.parameters["max_index_width"] + 1):
                    for column_permutation in itertools.permutations(
                        accessed_columns_per_table[table], index_width
                    ):
                        indexes_for_query.add(Index(list(column_permutation)))

            # Build index combinations based on added indexes
            for number_of_indexes_per_query in range(
                1, self.parameters["max_indexes_per_query"] + 1
            ):
                for index_combination in itertools.combinations(
                    indexes_for_query, number_of_indexes_per_query
                ):
                    index_combinations_for_workload.add(index_combination)

        # stores indexes that have a benefit in any combination
        #   (to prune indexes with no benefit)
        useful_indexes: Set[Index] = set()
        query_costs_for_index_combination = {}
        number_of_index_combinations = len(index_combinations_for_workload)
        logging.info(f"Evaluate {number_of_index_combinations} index combinations ")
        i = 0
        for index_combination in index_combinations_for_workload:
            i += 1
            if i % 10000 == 0:
                logging.info(f"  ... {i} / {number_of_index_combinations} done")
            is_useful_combination = False
            costs_per_query = {}
            for query in workload.queries:
                query_cost = self.cost_evaluation.calculate_cost(
                    Workload([query]), set(index_combination), store_size=True
                )
                # test if query_cost is lower than default cost
                if query_cost < self.query_costs_without_indexes[query]:
                    is_useful_combination = True
                    costs_per_query[query] = query_cost
            if is_useful_combination:
                query_costs_for_index_combination[index_combination] = costs_per_query
                for index in index_combination:
                    useful_indexes.add(index)
        logging.info(f"  ... {i} / {number_of_index_combinations} done")

        return useful_indexes, query_costs_for_index_combination

    def _calculate_best_indexes(self, workload: Workload) -> List:
        logging.info("Creating input for CoPhy")
        logging.info("Parameters: " + str(self.parameters))

        time_start = time.time()

        self.init_query_costs_without_indexes(workload)

        if self.parameters["enumeration"] == "full":
            useful_indexes, query_costs_for_index_combination = self.full_enumeration(
                workload
            )
        elif self.parameters["enumeration"] == "query-based":
            (
                useful_indexes,
                query_costs_for_index_combination,
            ) = self.query_based_enumeration(workload)
        else:
            assert False, f'Invalid enumeration type: {self.parameters["enumeration"]}'

        what_if_time = time.time() - time_start
        logging.info(f"What-if time: {what_if_time} s")
        # construct data structures to output later
        cophy_dict = {
            "what_if_time": what_if_time,
            "cost_requests": self.cost_evaluation.cost_requests,
            "cache_hits": self.cost_evaluation.cache_hits,
            "number_of_indexes": len(useful_indexes),
            "number_of_index_combinations": len(query_costs_for_index_combination),
            "queries": [],
            "index_sizes": [],
            "index_combinations": [],
            "query_costs": [],
        }

        # store included workload queries
        for query in workload.queries:
            cophy_dict["queries"].append(query.nr)

        # store index sizes and determine index_ids for later use in combinations
        index_ids = {}
        for i, index in enumerate(sorted(useful_indexes)):
            assert index.estimated_size, "Index size must be set."
            cophy_dict["index_sizes"].append(
                {
                    "index_id": i + 1,
                    "estimated_size": index.estimated_size,
                    "column_names": index._column_names(),
                }
            )
            index_ids[index] = i + 1

        # store indexes per combination
        # combination 0 := no index
        cophy_dict["index_combinations"].append({"combination_id": 0, "index_ids": ""})
        for i, index_combination in enumerate(query_costs_for_index_combination):
            index_id_list = [str(index_ids[index]) for index in index_combination]
            cophy_dict["index_combinations"].append(
                {"combination_id": i + 1, "index_ids": " ".join(index_id_list)}
            )

        # store query costs per query and index_combination
        for query in workload.queries:
            # Print cost without indexes
            cophy_dict["query_costs"].append(
                {
                    "query_number": query.nr,
                    "combination_id": 0,
                    "costs": self.query_costs_without_indexes[query],
                }
            )
            for i, index_combination in enumerate(query_costs_for_index_combination):
                # query is in dictionary if cost is lower than default
                if query in query_costs_for_index_combination[index_combination]:
                    cophy_dict["query_costs"].append(
                        {
                            "query_number": query.nr,
                            "combination_id": i + 1,
                            "costs": query_costs_for_index_combination[index_combination][
                                query
                            ],
                        }
                    )

        ampl_file_path = None
        json_file_path = None
        if self.parameters["output_folder"]:
            path_base = (
                self.parameters["output_folder"]
                + f'/{self.parameters["benchmark_name"]}_cophy_input'
                f'__width{self.parameters["max_index_width"]}'
                f'__per_query{self.parameters["max_indexes_per_query"]}'
            )
            if os.path.isfile(path_base + ".txt") and not self.parameters["overwrite"]:
                logging.info(
                    f"A datafile already exists for at {path_base + '.txt'}. "
                    f"Set parameter overwrite to True if you want to overwrite."
                    f"Output to stdout"
                )
            else:
                ampl_file_path = path_base + ".txt"
            if os.path.isfile(path_base + ".json") and not self.parameters["overwrite"]:
                logging.info(
                    f"A jsonfile already exists for at {path_base + '.json'}. "
                    f"Set parameter overwrite to True if you want to overwrite."
                    f"Output to stdout"
                )
            else:
                json_file_path = path_base + ".json"

        output_as_json(cophy_dict, json_file_path)
        output_as_ampl(cophy_dict, ampl_file_path)

        return []


def output_as_ampl(cophy_dict: Dict, file_path: str = None) -> None:
    if file_path is not None:
        folder = "/".join(file_path.split("/")[:-1])
        os.makedirs(folder, exist_ok=True)
        if os.path.isfile(file_path):
            logging.info(f"Overwriting {file_path}")
        handle = open(file_path, "w+")
    else:
        handle = sys.stdout

    handle.write(f'# what-if time: {cophy_dict["what_if_time"]}\n')
    handle.write(
        f'# cost_requests: {cophy_dict["cost_requests"]}\t'
        f'cache_hits: {cophy_dict["cache_hits"]}\n\n'
    )
    # This makes sure this file is treated as data
    handle.write("data;\n")
    handle.write(
        f'set QUERIES := {" ".join(str(q) for q in cophy_dict["queries"])};\n'
        f'param NUMBER_OF_INDEXES := {cophy_dict["number_of_indexes"]};\n'
        f"param NUMBER_OF_INDEX_COMBINATIONS := "
        f'{cophy_dict["number_of_index_combinations"]};\n\n\n'
    )
    handle.write("param size :=\n")
    for index_size_dict in cophy_dict["index_sizes"]:
        handle.write(
            f'{index_size_dict["index_id"]} {index_size_dict["estimated_size"]} '
            f'# {index_size_dict["column_names"]}\n'
        )
    handle.write(";\n\n")

    for combi_dict in cophy_dict["index_combinations"]:
        handle.write(
            f'set indexes_per_combination[{combi_dict["combination_id"]}]:= '
            f'{combi_dict["index_ids"]};\n'
        )

    handle.write("\nparam costs :=\n")
    for query_costs in cophy_dict["query_costs"]:
        handle.write(
            f'{query_costs["query_number"]} '
            f'{query_costs["combination_id"]} '
            f'{query_costs["costs"]}\n'
        )
    handle.write(";\n")
    logging.info(f"Wrote file to {file_path}")

    if handle is not sys.stdout:
        handle.close()
    return


def output_as_json(cophy_dict: Dict, json_path: str = None) -> None:
    if json_path is not None:
        folder = "/".join(json_path.split("/")[:-1])
        os.makedirs(folder, exist_ok=True)
        if os.path.isfile(json_path):
            logging.info(f"Overwriting {json_path}")
        handle = open(json_path, "w+")
    else:
        handle = sys.stdout

    json.dump(cophy_dict, handle, indent=4)
    logging.info(f"Wrote file to {json_path}")

    if handle is not sys.stdout:
        handle.close()
    return
