from pandas import DataFrame

from algorithm_examples.Mscn.source.mscn_model import MscnModel
from algorithm_examples.Mscn.source.mscn_utils import load_tokens, parse_queries, load_schema
from algorithm_examples.utils import load_training_sql
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEvent import PretrainingModelEvent
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData


class MscnPretrainingModelEvent(PretrainingModelEvent):

    def __init__(self, config: PilotConfig, bind_pilot_model: PilotModel, data_saving_table, enable_collection=True,
                 enable_training=True, training_data_file=None, num_collection = -1, num_training = -1, num_epoch = 100):
        super().__init__(config, bind_pilot_model, data_saving_table, enable_collection, enable_training)
        self.sqls = []
        self.config.once_request_timeout = 60
        self.config.sql_execution_timeout = 60
        self.pilot_data_interactor = PilotDataInteractor(self.config)
        self.training_data_file = training_data_file
        self.num_collection = num_collection
        self.num_training = num_training
        self.num_epoch = num_epoch

    def iterative_data_collection(self, db_controller: BaseDBController, train_data_manager: DataManager):
        print("start to collect data for MSCN algorithms")
        self.sqls = load_training_sql(self.config.db)
        if self.num_collection > 0:
            train_sqls = self.sqls[:self.num_collection]
        else:
            train_sqls = self.sqls
        column_2_value_list = []
        for i, sql in enumerate(train_sqls):
            # print per 10
            if i % 10 == 0:
                print("current is the {}-th sql, total is {}. (print per 10)".format(i, len(train_sqls)))
            self.pilot_data_interactor.pull_subquery_card()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            for sub_sql in data.subquery_2_card.keys():
                self.pilot_data_interactor.pull_record()
                data: PilotTransData = self.pilot_data_interactor.execute(sub_sql)
            if (not data.records is None):
                column_2_value = {"query": sub_sql, "card": int(data.records.values[0][0])}
            column_2_value_list.append(column_2_value)
        return column_2_value_list, True

    def custom_model_training(self, bind_pilot_model, db_controller: BaseDBController,
                              data_manager: DataManager):
        print("start to train model in {}".format(MscnPretrainingModelEvent))
        if not self.training_data_file is None:
            tokens, labels = load_tokens(self.training_data_file, self.training_data_file + ".token")
            schema = load_schema(self.pilot_data_interactor.db_controller)
            model = MscnModel()
            model.fit(tokens, labels + 1, schema)
        else:
            data: DataFrame = data_manager.read_all(self.data_saving_table)
            if self.num_training > 0:
                data = data[:self.num_training]
            print(f"Train mscn on {data.shape[0]} sql-card pairs")
            tables, joins, predicates = parse_queries(data["query"].values)
            schema = load_schema(self.pilot_data_interactor.db_controller)
            model = MscnModel()
            # Mscn can only handler card that is larger than 0, so we add 1 to all cards. In prediction we minus it by 1.
            model.fit((tables, joins, predicates), data["card"].values + 1, schema, num_epochs = self.num_epoch)
        return model
