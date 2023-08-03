import json

from pandas import DataFrame
from examples.Bao.source.SparkPlanCompress import SparkPlanCompress

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEvent import PeriodTrainingEvent, PretrainingModelEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData
from pilotscope.common.Util import json_str_to_json_obj
from pilotscope.common.dotDrawer import PlanDotDrawer
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler, modify_sql_for_spark
from examples.Bao.source.model import BaoRegression
from examples.utils import load_training_sql, to_tree_json
from pilotscope.PilotEnum import DatabaseEnum


class BaoPretrainingModelEvent(PretrainingModelEvent):

    def __init__(self, config: PilotConfig, bind_model: PilotModel, save_table_name, enable_collection=True,
                 enable_training=True):
        super().__init__(config, bind_model, save_table_name, enable_collection, enable_training)
        self.pilot_state_manager = PilotDataInteractor(self.config)
        self.bao_hint = BaoParadigmHintAnchorHandler.HintForBao(config.db_type)
        self.sqls = self.load_sql()
        self.cur_sql_idx = 0

    def load_sql(self):
        return load_training_sql(self.config.db)[0:10]  # only for development test

    def _custom_collect_data(self):
        # self.load_sql()
        column_2_value_list = []

        sql = self.sqls[self.cur_sql_idx]
        sql = modify_sql_for_spark(self.config, sql)

        print("current  is {}-th sql, and total sqls is {}".format(self.cur_sql_idx, len(self.sqls)))
        for hint2val in self.bao_hint.arms_hint2val:
            column_2_value = {}
            self.pilot_state_manager.push_hint(hint2val)
            self.pilot_state_manager.pull_physical_plan()
            self.pilot_state_manager.pull_execution_time()
            if self._model.have_cache_data:
                self.pilot_state_manager.pull_buffercache()
            data: PilotTransData = self.pilot_state_manager.execute(sql)
            if data is not None and data.execution_time is not None:
                column_2_value["plan"] = data.physical_plan
                column_2_value["sql"] = sql
                if self._model.have_cache_data:
                    column_2_value["plan"]["Buffers"] = data.buffercache
                column_2_value["time"] = data.execution_time
                column_2_value["sql_idx"] = self.cur_sql_idx
                column_2_value_list.append(column_2_value)
        self.cur_sql_idx += 1
        return column_2_value_list, True if self.cur_sql_idx >= len(self.sqls) else False

    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        data: DataFrame = train_data_manager.read_all(self.save_table_name)
        bao_model = BaoRegression(verbose=True, have_cache_data=self._model.have_cache_data,
                                  is_spark=self.config.db_type == DatabaseEnum.SPARK)
        new_plans, new_times = self.filter(data["plan"].values, data["time"].values)
        bao_model.fit(new_plans, new_times)
        return bao_model

    def filter(self, plans, times):
        new_plans = []
        new_times = []

        for i, plan in enumerate(plans):
            if self.config.db_type == DatabaseEnum.POSTGRESQL and not self.contain_outlier_plan(plan):
                new_plans.append(plan)
                new_times.append(times[i])
            elif self.config.db_type == DatabaseEnum.SPARK:
                plan = to_tree_json(plan)
                compress = SparkPlanCompress()
                plan["Plan"] = compress.compress(plan["Plan"])
                new_plans.append(plan)
                new_times.append(times[i])
        return new_plans, new_times

    def contain_outlier_plan(self, plan):
        if isinstance(plan, str):
            plan = json_str_to_json_obj(plan)["Plan"]
        children = plan["Plans"] if "Plans" in plan else []
        for child in children:
            flag = self.contain_outlier_plan(child)
            if flag:
                return True

        if plan["Node Type"] == "BitmapAnd":
            return True
        return False


class BaoPeriodTrainingEvent(PeriodTrainingEvent):

    def __init__(self, train_data_table, config, per_query_count, model: PilotModel):
        super().__init__(config, per_query_count, model)
        self.train_data_table = train_data_table

    def custom_update(self, existed_user_model, pilot_data_manager: PilotTrainDataManager):
        data = pilot_data_manager.read_all(self.train_data_table)
        # print(data)
        # exit()
        bao_model = BaoRegression(verbose=True, have_cache_data=self.model.have_cache_data)
        X = data["physical_plan"].values
        if self.model.have_cache_data:
            buffercache = data["buffercache"].values
            if self.model.have_cache_data:
                for i in range(len(X)):
                    X[i] = json.loads(X[i])
                    X[i]["Buffers"] = json.loads(buffercache[i])
        bao_model.fit(X, data["execution_time"].values)
        return bao_model
