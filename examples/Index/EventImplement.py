import random

from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotEnum import ExperimentTimeEnum
from pilotscope.PilotEvent import PeriodicDbControllerEvent
from pilotscope.common.Index import Index as PilotIndex
from pilotscope.common.TimeStatistic import TimeStatistic
from examples.utils import load_training_sql, to_pilot_index, load_test_sql
from examples.Index.index_selection_evaluation.selection.algorithms.extend_algorithm import ExtendAlgorithm
from examples.Index.index_selection_evaluation.selection.index_selection_evaluation import to_workload
from examples.Index.index_selection_evaluation.selection.workload import Query


class DbConnector:

    def __init__(self, data_interactor: PilotDataInteractor):
        super().__init__()
        self.data_interactor = data_interactor
        self.db_controller = data_interactor.db_controller

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

        connector = DbConnector(PilotDataInteractor(self.config, DBControllerFactory.get_db_controller(self.config,
                                                                                                     enable_simulate_index=True)))
        algo = ExtendAlgorithm(connector, parameters=parameters)
        indexes = algo.calculate_best_indexes(workload)
        for index in indexes:
            columns = [c.name for c in index.columns]
            db_controller.create_index(PilotIndex(columns, index.table().name, index.index_idx()))
            print("create index {}".format(index))
        TimeStatistic.end(ExperimentTimeEnum.FIND_INDEX)
