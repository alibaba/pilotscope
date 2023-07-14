import random

from DBController.BaseDBController import BaseDBController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotEnum import ExperimentTimeEnum
from PilotEvent import PeriodicDbControllerEvent
from common.Index import Index as PilotIndex
from common.TimeStatistic import TimeStatistic
from examples.utils import load_training_sql, to_pilot_index, load_test_sql
from selection.algorithms.extend_algorithm import ExtendAlgorithm
from selection.index_selection_evaluation import to_workload
from selection.workload import Query


class DbConnector:

    def __init__(self, state_manager: PilotStateManager):
        super().__init__()
        self.state_manager = state_manager
        self.db_controller = state_manager.db_controller

    def get_cost(self, query: Query):
        return self.db_controller.get_estimated_cost(query.text)

    def drop_indexes(self):
        self.db_controller.drop_all_indexes()

    def drop_index(self, index):
        self.db_controller.drop_index(to_pilot_index(index))

    def get_index_byte(self, index):
        return self.db_controller.get_index_byte(index)

    def get_config(self):
        return self.db_controller.config


class IndexPeriodicDbControllerEvent(PeriodicDbControllerEvent):

    def _load_sql(self):
        sqls: list = load_test_sql(self.config.db)
        random.shuffle(sqls)
        if "imdb" in self.config.db:
            sqls = sqls[0:len(sqls) // 2]
        return sqls

    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):
        TimeStatistic.start(ExperimentTimeEnum.FIND_INDEX)
        db_controller.drop_all_indexes()
        sqls = self._load_sql()
        workload = to_workload(sqls)
        parameters = {
            "benchmark_name": self.config.db, "budget_MB": 250, "max_index_width": 2
        }

        connector = DbConnector(PilotStateManager(self.config, DBControllerFactory.get_db_controller(self.config,
                                                                                                     enable_simulate_index=True)))
        algo = ExtendAlgorithm(connector, parameters=parameters)
        indexes = algo.calculate_best_indexes(workload)
        for index in indexes:
            columns = [c.name for c in index.columns]
            db_controller.create_index(PilotIndex(columns, index.table().name, index.index_idx()))
            print("create index {}".format(index))
        TimeStatistic.end(ExperimentTimeEnum.FIND_INDEX)
