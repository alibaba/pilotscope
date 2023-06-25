from abc import ABC, abstractmethod

from Dao.PilotTrainDataManager import PilotTrainDataManager
from common.Cache import Cache


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.user_model = None
        self.pilot_model_Cache = Cache(model_name)

    def save(self):
        self._save_user_model(self.user_model)
        self.pilot_model_Cache.save([self.model_name])

    def load(self):
        self.user_model = self._load_user_model()
        if self.pilot_model_Cache.exist():
            res = self.pilot_model_Cache.read()
            self.model_name = res[0]

    @abstractmethod
    def _save_user_model(self, user_model):
        pass

    @abstractmethod
    def _load_user_model(self):
        pass
