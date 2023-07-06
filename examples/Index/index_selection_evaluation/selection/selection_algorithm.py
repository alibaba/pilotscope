import logging

from DBController.BaseDBController import BaseDBController
from selection.cost_evaluation import CostEvaluation

# If not specified by the user, algorithms should use these default parameter values to
# avoid diverging values for different algorithms.
DEFAULT_PARAMETER_VALUES = {
    "budget_MB": 500,
    "max_indexes": 15,
    "max_index_width": 2,
}


class SelectionAlgorithm:
    def __init__(self, database_connector, parameters, default_parameters=None):
        if default_parameters is None:
            default_parameters = {}
        logging.debug("Init selection algorithm")
        self.did_run = False
        self.parameters = parameters
        # Store default values for missing parameters
        for key, value in default_parameters.items():
            if key not in self.parameters:
                self.parameters[key] = value

        self.database_connector = database_connector
        self.database_connector.drop_indexes()
        self.cost_evaluation = CostEvaluation(database_connector)
        if "cost_estimation" in self.parameters:
            estimation = self.parameters["cost_estimation"]
            self.cost_evaluation.cost_estimation = estimation

    def calculate_best_indexes(self, workload):
        assert self.did_run is False, "Selection algorithm can only run once."
        self.did_run = True
        indexes = self._calculate_best_indexes(workload)
        self._log_cache_hits()
        self.cost_evaluation.complete_cost_estimation()

        return indexes

    def _calculate_best_indexes(self, workload):
        raise NotImplementedError("_calculate_best_indexes(self, " "workload) missing")

    def _log_cache_hits(self):
        hits = self.cost_evaluation.cache_hits
        requests = self.cost_evaluation.cost_requests
        logging.debug(f"Total cost cache hits:\t{hits}")
        logging.debug(f"Total cost requests:\t\t{requests}")
        if requests == 0:
            return
        ratio = round(hits * 100 / requests, 2)
        logging.debug(f"Cost cache hit ratio:\t{ratio}%")


class NoIndexAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(self, database_connector, parameters)

    def _calculate_best_indexes(self, workload):
        return []


class AllIndexesAlgorithm(SelectionAlgorithm):
    def __init__(self, database_connector, parameters=None):
        if parameters is None:
            parameters = {}
        SelectionAlgorithm.__init__(self, database_connector, parameters)

    # Returns single column index for each indexable column
    def _calculate_best_indexes(self, workload):
        return workload.potential_indexes()
