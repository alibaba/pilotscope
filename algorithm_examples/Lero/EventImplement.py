import json

from pandas import DataFrame

from algorithm_examples.Lero.LeroPilotAdapter import CardsPickerModel
from algorithm_examples.Lero.source.train import training_pairwise_pilot_score, get_training_pair
from algorithm_examples.utils import load_training_sql
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.DataManager import DataManager
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

    def __init__(self, config: PilotConfig, bind_pilot_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True):
        super().__init__(config, bind_pilot_model, data_saving_table, enable_collection, enable_training)
        self.sqls = []
        self.pilot_data_interactor = PilotDataInteractor(self.config)

    def load_sql(self):
        self.sqls = load_training_sql(self.config.db)

    def iterative_data_collection(self, db_controller: BaseDBController, train_data_manager: DataManager):
        print("start to collect data for pretraining")
        self.load_sql()

        column_2_value_list = []

        for i, sql in enumerate(self.sqls):
            print("current  is {}-th sql, and total sqls is {}".format(i, len(self.sqls)))
            self.pilot_data_interactor.pull_subquery_card()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            if data is None:
                continue
            subquery_2_card = data.subquery_2_card
            cards_picker = CardsPickerModel(subquery_2_card.keys(), subquery_2_card.values())
            scale_subquery_2_card = subquery_2_card
            finish = False
            while(not finish):
                column_2_value = {}
                self.pilot_data_interactor.push_card(scale_subquery_2_card)
                self.pilot_data_interactor.pull_physical_plan()
                self.pilot_data_interactor.pull_execution_time()
                data: PilotTransData = self.pilot_data_interactor.execute(sql)
                if data is None:
                    print(f"Warning: timeout in collecting data. {i}-th sql skiped. Try to enlarge 'timeout' in config to collect.")
                    break
                plan = data.physical_plan
                cards_picker.replace(plan)
                column_2_value["sql"] = sql
                column_2_value["plan"] = plan
                column_2_value["time"] = data.execution_time
                finish, new_cards = cards_picker.get_cards()
                scale_subquery_2_card = {sq : new_card for sq, new_card in zip(subquery_2_card.keys(), new_cards)}
                column_2_value_list.append(column_2_value)
        return column_2_value_list, True

    def custom_model_training(self, bind_pilot_model, db_controller: BaseDBController,
                              data_manager: DataManager):
        data: DataFrame = data_manager.read_all(self.data_saving_table)
        plans1, plans2 = extract_plan_pairs(data)
        lero_model = training_pairwise_pilot_score(bind_pilot_model, plans1, plans2)
        return lero_model


class LeroPeriodicModelUpdateEvent(PeriodicModelUpdateEvent):
    def __init__(self, train_data_table, config, per_query_count, pilot_model: PilotModel):
        super().__init__(config, per_query_count, pilot_model)
        self.train_data_table = train_data_table

    def custom_model_update(self, pilot_model: PilotModel, db_controller: BaseDBController,
                            data_manager: DataManager):
        print("LeroPeriodTrainingEvent!!!")
        data = data_manager.read_update(self.train_data_table)
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

    def process(self, db_controller: BaseDBController, data_manager: DataManager):
        print("start to collect data for dynamic training")
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
            cards_picker = CardsPickerModel(subquery_2_card.keys(), subquery_2_card.values())
            scale_subquery_2_card = subquery_2_card
            finish = False
            while(not finish):
                column_2_value = {}
                data_interactor.push_card(scale_subquery_2_card)
                data_interactor.pull_physical_plan()
                data_interactor.pull_execution_time()
                data: PilotTransData = data_interactor.execute(sql)
                if data is None:
                    continue
                plan = data.physical_plan
                cards_picker.replace(plan)
                column_2_value["sql"] = sql
                column_2_value["plan"] = data.physical_plan
                column_2_value["time"] = data.execution_time
                finish, new_cards = cards_picker.get_cards()
                scale_subquery_2_card = {sq : new_card for sq, new_card in zip(subquery_2_card.keys(), new_cards)}
                column_2_value_list.append(column_2_value)
        data_manager.save_data_batch(self._table_name, column_2_value_list)
