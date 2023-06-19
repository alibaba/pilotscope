import json

from pandas import DataFrame

from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from examples.Lero.LeroParadigmCardAnchorHandler import scale_card
from examples.Lero.source.train import training_pairwise_pilot_score, get_training_pair
from Interface.PretrainingEventInterface import PretrainingEventInterface
from PilotConfig import PilotConfig
from PilotModel import PilotModel
from PilotTransData import PilotTransData
from examples.utils import load_sql


class LeroPretrainingEventInterface(PretrainingEventInterface):

    def __init__(self, config: PilotConfig, model: PilotModel):
        super().__init__(config, model)
        self.sqls = []
        self.pilot_state_manager = PilotStateManager(self.config)

    def load_sql(self):
        self.sqls = load_sql(self.config.stats_train_sql_file_path)

    def _custom_collect_data(self):
        self.load_sql()
        factors = [-10, 1, 10]
        column_2_value_list = []

        for sql in self.sqls:
            self.pilot_state_manager.fetch_subquery_card()
            data: PilotTransData = self.pilot_state_manager.execute(sql)
            subquery_2_card = data.subquery_2_card
            for f in factors:
                column_2_value = {}
                scale_subquery_2_card = scale_card(subquery_2_card, f)
                self.pilot_state_manager.set_card(scale_subquery_2_card)
                self.pilot_state_manager.fetch_physical_plan()
                self.pilot_state_manager.fetch_execution_time()
                data = self.pilot_state_manager.execute(sql)
                column_2_value["sql"] = sql
                column_2_value["plan"] = data.physical_plan
                column_2_value["time"] = data.execution_time
                column_2_value["scale"] = f
                column_2_value_list.append(column_2_value)
        return column_2_value_list

    def _get_table_name(self):
        return "lero_pretraining_collect_data"

    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager):
        data: DataFrame = train_data_manager.read_all(self._get_table_name())
        plans1, plans2 = self._extract_plan_pair(data)
        lero_model = training_pairwise_pilot_score(None, None, plans1, plans2)
        return lero_model

    def _extract_plan_pair(self, data: DataFrame):
        sql_2_plans = {}
        sqls = data["sql"].unique()
        for sql in sqls:
            if sql not in sql_2_plans:
                sql_2_plans[sql] = []
            rows = data[data["sql"] == sql]
            for row in rows:
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
