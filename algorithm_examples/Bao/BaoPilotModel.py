import os

from pilotscope.DataManager.DataManager import DataManager
from pilotscope.PilotModel import PilotModel
from algorithm_examples.Bao.source.model import BaoRegression


class BaoPilotModel(PilotModel):

    def __init__(self, model_name, have_cache_data=False, is_spark=False):
        super().__init__(model_name)
        self.bao_model_save_dir = "../algorithm_examples/ExampleData/Bao/Model"
        self.model_path = os.path.join(self.bao_model_save_dir, self.model_name)
        self.have_cache_data = have_cache_data
        self.is_spark = is_spark

    def train(self, data_manager: DataManager):
        print("enter LeroPilotModel.train")

    def update(self, data_manager: DataManager):
        print("enter LeroPilotModel.update")

    def save_model(self):
        self.model.save(self.model_path)

    def load_model(self):
        try:
            bao_model = BaoRegression(have_cache_data=self.have_cache_data, is_spark=self.is_spark)
            bao_model.load(self.model_path)
        except FileNotFoundError:
            bao_model = BaoRegression(have_cache_data=self.have_cache_data, is_spark=self.is_spark)
        self.model = bao_model
