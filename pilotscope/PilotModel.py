from abc import ABC, abstractmethod


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None

    def save(self):
        self._save_model(self.model)

    def load(self):
        self.model = self._load_model()

    @abstractmethod
    def _save_model(self, user_model):
        pass

    @abstractmethod
    def _load_model(self):
        pass
