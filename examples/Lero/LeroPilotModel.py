import os

from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotModel import PilotModel
from model import LeroModelPairWise


class LeroPilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.lero_model_save_dir = "../examples/ExampleData/Lero/Model"
        self.model_path = os.path.join(self.lero_model_save_dir, self.model_name)

    def train(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.train")

    def update(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.update")

    def _save_user_model(self, user_model):
        user_model.save(self.model_path)

    def _load_user_model(self):
        try:
            lero_model = LeroModelPairWise(None)
            lero_model.load(self.model_path)
        except FileNotFoundError:
            lero_model = LeroModelPairWise(None)
        return lero_model
