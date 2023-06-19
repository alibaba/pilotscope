from abc import ABC, abstractmethod

from Dao.PilotTrainDataManager import PilotTrainDataManager
from common.Cache import Cache


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None
        self.is_finished_pretraining = False
        self.pilot_model_Cache = Cache(model_name)

    def save_pilot_model(self):
        self._save_user_model()
        self.pilot_model_Cache.save([self.model_name, self.is_finished_pretraining])

    def load(self):
        self._load_user_model()
        if self.pilot_model_Cache.exist():
            res = self.pilot_model_Cache.read()
            self.model_name = res[0]
            self.is_finished_pretraining = res[1]

    @abstractmethod
    def train(self, pilot_data_manager: PilotTrainDataManager):
        pass

    @abstractmethod
    def update(self, pilot_data_manager: PilotTrainDataManager):
        pass

    @abstractmethod
    def _save_user_model(self):
        pass

    @abstractmethod
    def _load_user_model(self):
        pass
