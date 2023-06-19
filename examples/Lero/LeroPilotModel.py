from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotModel import PilotModel
from model import LeroModelPairWise


class LeroPilotModel(PilotModel):

    def __init__(self, model_name):
        super().__init__(model_name)
        self.lero_model_save_dir = "examples/ExampleData/Lero/Model"

    def train(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.train")

    def update(self, pilot_data_manager: PilotTrainDataManager):
        print("enter LeroPilotModel.update")

    def _save_user_model(self):
        self.model.save(self.lero_model_save_dir)

    def _load_user_model(self):
        try:
            lero_model = LeroModelPairWise(None)
            lero_model.load(self.lero_model_save_dir)
            self.model = lero_model
        except FileNotFoundError:
            self.model = None
