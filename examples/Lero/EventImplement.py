import json

from pandas import DataFrame

from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEvent import PeriodTrainingEvent, PretrainingModelEvent
from PilotModel import PilotModel
from PilotTransData import PilotTransData
from examples.Lero.LeroParadigmCardAnchorHandler import scale_card
from examples.Lero.source.train import training_pairwise_pilot_score, get_training_pair
from examples.utils import load_sql


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

    def __init__(self, config: PilotConfig, bind_model: PilotModel, enable_collection=True, enable_training=True):
        super().__init__(config, bind_model, enable_collection, enable_training)
        self.sqls = []
        self.pilot_state_manager = PilotStateManager(self.config)

    def load_sql(self):
        self.sqls = load_sql("../examples/stats_train.txt")[0:200]

    def _custom_collect_data(self):
        print("start to collect data fro pretraining")
        self.load_sql()
        factors = [0.1, 1, 10]
        # factors = [10]
        column_2_value_list = []

        for i, sql in enumerate(self.sqls):
            print("current  is {}-th sql, and total sqls is {}".format(i, len(self.sqls)))
            self.pilot_state_manager.fetch_subquery_card()
            data: PilotTransData = self.pilot_state_manager.execute(sql)
            if data is None:
                continue
            subquery_2_card = data.subquery_2_card
            for f in factors:
                column_2_value = {}
                scale_subquery_2_card = scale_card(subquery_2_card, f)
                self.pilot_state_manager.set_card(scale_subquery_2_card)
                self.pilot_state_manager.fetch_physical_plan()
                self.pilot_state_manager.fetch_execution_time()
                data: PilotTransData = self.pilot_state_manager.execute(sql)
                if data is None:
                    continue
                column_2_value["sql"] = sql
                column_2_value["plan"] = data.physical_plan
                column_2_value["time"] = data.execution_time
                column_2_value["scale"] = f
                column_2_value_list.append(column_2_value)
        return column_2_value_list

    def _get_table_name(self):
        return "lero_pretraining_collect_data"

    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        data: DataFrame = train_data_manager.read_all(self._get_table_name())
        plans1, plans2 = extract_plan_pairs(data)
        lero_model = training_pairwise_pilot_score(existed_user_model, plans1, plans2)
        return lero_model


class LeroPeriodTrainingEvent(PeriodTrainingEvent):

    def __init__(self, train_data_table, config, per_query_count, model: PilotModel):
        super().__init__(config, per_query_count, model)
        self.train_data_table = train_data_table

    def custom_update(self, existed_user_model, pilot_data_manager: PilotTrainDataManager):
        data = pilot_data_manager.read_update(self.train_data_table)
        plans1, plans2 = extract_plan_pairs(data)
        lero_model = training_pairwise_pilot_score(existed_user_model, plans1, plans2)
        return lero_model
