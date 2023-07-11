from DBController.BaseDBController import BaseDBController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotEnum import ExperimentTimeEnum
from PilotEvent import PeriodicDbControllerEvent
from common.TimeStatistic import TimeStatistic
from examples.utils import load_training_sql
from selection.algorithms.extend_algorithm import ExtendAlgorithm
from selection.index_selection_evaluation import to_workload
from selection.workload import Query


class DbConnector:

    def __init__(self, db_controller: BaseDBController):
        super().__init__()
        self.db_controller = db_controller

    def get_cost(self, query: Query):
        return self.db_controller.get_estimated_cost(query.text)

    def drop_indexes(self):
        self.db_controller.drop_all_indexes()

    def drop_index(self, index):
        self.db_controller.drop_index(index.index_idx())

    def get_index_byte(self, index_name):
        return self.db_controller.get_index_byte(index_name)

    def get_config(self):
        return self.db_controller.config


class IndexPeriodicDbControllerEvent(PeriodicDbControllerEvent):

    def _load_sql(self):
        return load_training_sql(self.config.db)[0:20]

    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):
        TimeStatistic.start(ExperimentTimeEnum.FIND_INDEX)
        db_controller.drop_all_indexes()
        sqls = self._load_sql()
        workload = to_workload(sqls)
        parameters = {
            "benchmark_name": self.config.db, "budget_MB": 250, "max_index_width": 2
        }
        connector = DbConnector(db_controller)
        algo = ExtendAlgorithm(connector, parameters=parameters)
        indexes = algo.calculate_best_indexes(workload)
        for index in indexes:
            columns = [c.name for c in index.columns]
            db_controller.create_index(index.index_idx(), index.table().name, columns)
        TimeStatistic.end(ExperimentTimeEnum.FIND_INDEX)

