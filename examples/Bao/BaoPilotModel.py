import os

from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotModel import PilotModel
from examples.Bao.source.model import BaoRegression
# from model import BaoRegression


class BaoPilotModel(PilotModel):

    def __init__(self, model_name, have_cache_data=False):
        super().__init__(model_name)
        self.bao_model_save_dir = "../examples/ExampleData/Bao/Model"
        self.model_path = os.path.join(self.bao_model_save_dir, self.model_name)
        self.have_cache_data = have_cache_data

    def train(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.train")

    def update(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.update")

    def _save_user_model(self, user_model):
        user_model.save(self.model_path)

    def _load_user_model(self):
        try:
            bao_model = BaoRegression(have_cache_data=self.have_cache_data)
            bao_model.load(self.model_path)
        except FileNotFoundError:
            bao_model = BaoRegression(have_cache_data=self.have_cache_data)
        return bao_model
