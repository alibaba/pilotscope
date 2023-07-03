import json

from pandas import DataFrame

from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEvent import PeriodTrainingEvent, PretrainingModelEvent
from PilotModel import PilotModel
from PilotTransData import PilotTransData
from examples.utils import load_sql
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler
from examples.Bao.source.model import BaoRegression

class BaoPretrainingModelEvent(PretrainingModelEvent):

    def __init__(self, config: PilotConfig, bind_model: PilotModel, enable_collection=True, enable_training=True):
        super().__init__(config, bind_model, enable_collection, enable_training)
        self.sqls = []
        self.pilot_state_manager = PilotStateManager(self.config)
        self.bao_hint = BaoParadigmHintAnchorHandler.HintForBao(config.db_type)

    def load_sql(self):
        self.sqls = load_sql("../examples/stats_train.txt")[0:20] # only for development test

    def _custom_collect_data(self):
        self.load_sql()
        column_2_value_list = []
        for sql in self.sqls:
            for hint2val in self.bao_hint.arms_hint2val:
                column_2_value={}
                self.pilot_state_manager.db_controller.connect()
                self.pilot_state_manager.set_hint(hint2val)
                self.pilot_state_manager.fetch_physical_plan()
                self.pilot_state_manager.fetch_execution_time()
                if self._model.have_cache_data:
                    self.pilot_state_manager.fetch_buffercache()
                data: PilotTransData = self.pilot_state_manager.execute(sql)
                if data is not None and data.execution_time is not None:
                    column_2_value["plan"] = data.physical_plan
                    if self._model.have_cache_data:
                        column_2_value["plan"]["Buffers"] = data.buffercache
                    column_2_value["time"] = data.execution_time
                    column_2_value_list.append(column_2_value)
        return column_2_value_list

    def _get_table_name(self):
        if not self._model.have_cache_data:
            return "bao_pretraining_collect_data"
        else:
            return "bao_pretraining_collect_data_wc"

    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        data: DataFrame = train_data_manager.read_all(self._get_table_name())
        bao_model = BaoRegression(verbose = True, have_cache_data = self._model.have_cache_data)
        bao_model.fit(data["plan"].values, data["time"].values)
        return bao_model


class BaoPeriodTrainingEvent(PeriodTrainingEvent):

    def __init__(self, train_data_table, config, per_query_count, model: PilotModel):
        super().__init__(config, per_query_count, model)
        self.train_data_table = train_data_table
    
    def custom_update(self, existed_user_model, pilot_data_manager: PilotTrainDataManager):
        data = pilot_data_manager.read_all(self.train_data_table)
        # print(data)
        # exit()
        bao_model = BaoRegression(verbose = True, have_cache_data = self.model.have_cache_data)
        X = data["physical_plan"].values
        if self.model.have_cache_data:
            buffercache = data["buffercache"].values
            if self.model.have_cache_data:
                for i in range(len(X)):
                    X[i] = json.loads(X[i])
                    X[i]["Buffers"] = json.loads(buffercache[i])
        bao_model.fit(X , data["execution_time"].values)
        return bao_model
