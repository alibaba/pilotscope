import json
from abc import ABC

from pandas import DataFrame

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEvent import PeriodTrainingEvent, PretrainingModelEvent, PeriodPerCountCollectionDataEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData
from examples.Mscn.source.mscn_utils import load_tokens, parse_queries, load_schema
from examples.Mscn.source.mscn_model import MscnModel
from examples.utils import load_sql,load_training_sql

class MscnPretrainingModelEvent(PretrainingModelEvent):

    def __init__(self, config: PilotConfig, bind_model: PilotModel, save_table_name, enable_collection=True, enable_training=True, training_data_file = None):
        super().__init__(config, bind_model, save_table_name, enable_collection, enable_training)
        self.sqls = []
        self.pilot_data_interactor = PilotDataInteractor(self.config)
        self.training_data_file = training_data_file

    def _custom_collect_data(self):
        self.sqls = load_training_sql(self.config.db)
        column_2_value_list = []
        for sql in self.sqls:
            print(sql,flush = True)
            # self.pilot_data_interactor.pull_subquery_card()
            # data: PilotTransData = self.pilot_data_interactor.execute(sql)
            # for sub_sql in data.subquery_2_card.keys():
            self.pilot_data_interactor.pull_record()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            column_2_value={"query": sql, "card": data.records[0][0]}
            if(data.records[0][0]>0): # Mscn can only handler card that is larger than 0
                print(column_2_value)
                column_2_value_list.append(column_2_value)
        return column_2_value_list, True
    
    def _get_table_name(self):
        return self.save_table_name

    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager, existed_user_model):
        if not self.training_data_file is None:
            tokens, labels = load_tokens(self.training_data_file, self.training_data_file+".token")
            schema = load_schema(self.pilot_data_interactor.db_controller)
            model = MscnModel()
            model.fit(tokens, labels, schema)
        else:
            data: DataFrame = train_data_manager.read_all(self._get_table_name())
            tables, joins, predicates = parse_queries(data["query"].values)
            schema = load_schema(self.pilot_data_interactor.db_controller)
            model = MscnModel()
            model.fit((tables, joins, predicates), data["card"].values, schema)
        return model
