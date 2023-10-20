import json

from pandas import DataFrame

from algorithm_examples.Lero.LeroParadigmCardAnchorHandler import scale_card
from algorithm_examples.Lero.source.train import training_pairwise_pilot_score, get_training_pair
from algorithm_examples.utils import load_training_sql
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEvent import PeriodicModelUpdateEvent, PretrainingModelEvent, QueryFinishEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData


def extract_plan_pairs(data: DataFrame):
    sql_2_plans = {}
    sqls = list(data["sql"].unique())
    for sql in sqls:
        if sql not in sql_2_plans:
            sql_2_plans[sql] = []
        rows = data[data["sql"] == sql]
        for idx, row in rows.iterrows():
            plan_json = json.loads(row["plan"])
            plan_json["Execution Time"] = row["time"]
            sql_2_plans[sql].append(json.dumps(plan_json))

    # build pair
    plans1 = []
    plans2 = []
    for sql in sqls:
        plans = sql_2_plans[sql]
        if len(plans) == 1:
            continue
        p1, p2 = get_training_pair(plans)
        plans1 += p1
        plans2 += p2
    return plans1, plans2


class LeroPretrainingModelEvent(PretrainingModelEvent):

    def __init__(self, config: PilotConfig, bind_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True):
        super().__init__(config, bind_model, data_saving_table, enable_collection, enable_training)
        self.sqls = []
        self.pilot_data_interactor = PilotDataInteractor(self.config)

    def load_sql(self):
        self.sqls = load_training_sql(self.config.db)[0:100]

    def iterative_data_collection(self,db_controller: BaseDBController, train_data_manager: PilotTrainDataManager):
        print("start to collect data fro pretraining")
        self.load_sql()
        factors = [0.1, 1, 10]
        # factors = [10]
        column_2_value_list = []

        for i, sql in enumerate(self.sqls):
            print("current  is {}-th sql, and total sqls is {}".format(i, len(self.sqls)))
            self.pilot_data_interactor.pull_subquery_card()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            if data is None:
                continue
            subquery_2_card = data.subquery_2_card
            for f in factors:
                column_2_value = {}
                scale_subquery_2_card = scale_card(subquery_2_card, f)
                self.pilot_data_interactor.push_card(scale_subquery_2_card)
                self.pilot_data_interactor.pull_physical_plan()
                self.pilot_data_interactor.pull_execution_time()
                data: PilotTransData = self.pilot_data_interactor.execute(sql)
                if data is None:
                    continue
                column_2_value["sql"] = sql
                column_2_value["plan"] = data.physical_plan
                column_2_value["time"] = data.execution_time
                column_2_value["scale"] = f
                column_2_value_list.append(column_2_value)
        return column_2_value_list, True

    def custom_model_training(self, bind_model, db_controller: BaseDBController,
                              train_data_manager: PilotTrainDataManager):
        data: DataFrame = train_data_manager.read_all(self.data_saving_table)
        plans1, plans2 = extract_plan_pairs(data)
        lero_model = training_pairwise_pilot_score(bind_model, plans1, plans2)
        return lero_model


class LeroPeriodicModelUpdateEvent(PeriodicModelUpdateEvent):
    def __init__(self, train_data_table, config, per_query_count, pilot_model: PilotModel):
        super().__init__(config, per_query_count, pilot_model)
        self.train_data_table = train_data_table

    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            pilot_data_manager: PilotTrainDataManager):
        print("LeroPeriodTrainingEvent!!!")
        data = pilot_data_manager.read_update(self.train_data_table)
        plans1, plans2 = extract_plan_pairs(data)
        lero_model = training_pairwise_pilot_score(pilot_model, plans1, plans2)
        return lero_model


class LeroPeriodicCollectEvent(QueryFinishEvent):
    def __init__(self, save_table_name, config, per_query_count):
        super().__init__(config, per_query_count)
        self.offset = 0
        self._table_name = save_table_name

    def load_per_sqls(self):
        sql_all = load_training_sql(self.config.db)
        sqls = sql_all[self.offset * self.interval_count:(self.offset + 1) * self.interval_count]
        self.offset += 1
        return sqls

    def process(self, db_controller: BaseDBController, pilot_data_manager: PilotTrainDataManager):
        print("start to collect data for dynamic training")
        factors = [0.1, 1, 10]
        column_2_value_list = []
        sqls = self.load_per_sqls()
        data_interactor = PilotDataInteractor(self.config)
        for i, sql in enumerate(sqls):
            print("Collecting {}-th sql".format(i + (self.offset - 1) * self.per_query_count))
            data_interactor.pull_subquery_card()
            data: PilotTransData = data_interactor.execute(sql)
            if data is None:
                continue
            subquery_2_card = data.subquery_2_card
            for f in factors:
                column_2_value = {}
                scale_subquery_2_card = scale_card(subquery_2_card, f)
                data_interactor.push_card(scale_subquery_2_card)
                data_interactor.pull_physical_plan()
                data_interactor.pull_execution_time()
                data: PilotTransData = data_interactor.execute(sql)
                if data is None:
                    continue
                column_2_value["sql"] = sql
                column_2_value["plan"] = data.physical_plan
                column_2_value["time"] = data.execution_time
                column_2_value["scale"] = f
                column_2_value_list.append(column_2_value)
        pilot_data_manager.save_data_batch(self._table_name, column_2_value_list)
