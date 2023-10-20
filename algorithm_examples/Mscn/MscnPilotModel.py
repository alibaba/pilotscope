import os

from pilotscope.DataManager.DataManager import DataManager
from pilotscope.PilotModel import PilotModel
from algorithm_examples.Mscn.source.mscn_model import MscnModel


class MscnPilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.lero_model_save_dir = "../algorithm_examples/ExampleData/Mscn/Model"
        self.model_path = os.path.join(self.lero_model_save_dir, self.model_name)

    def _save_model(self, user_model):
        user_model.save(self.model_path)

    def _load_model(self):
        try:
            model = MscnModel()
            model.load(self.model_path)
            print(f"Model loaded: {self.model_path}")
        except:
            model = MscnModel()
        return model
