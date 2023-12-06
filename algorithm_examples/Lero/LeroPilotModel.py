import os

from algorithm_examples.Lero.source.model import LeroModelPairWise
from pilotscope.DataManager.DataManager import DataManager
from pilotscope.PilotModel import PilotModel


class LeroPilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.lero_model_save_dir = "../algorithm_examples/ExampleData/Lero/Model"
        self.model_path = os.path.join(self.lero_model_save_dir, self.model_name)

    def train(self, data_manager: DataManager):
        print("enter LeroPilotModel.train")

    def update(self, data_manager: DataManager):
        print("enter LeroPilotModel.update")

    def save_model(self):
        self.model.save(self.model_path)

    def load_model(self):
        try:
            lero_model = LeroModelPairWise(None)
            lero_model.load(self.model_path)
        except FileNotFoundError:
            lero_model = LeroModelPairWise(None)
        self.model = lero_model
