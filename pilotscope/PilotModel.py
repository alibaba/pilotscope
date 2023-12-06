from abc import ABC, abstractmethod


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None

    @abstractmethod
    def save_model(self):
        raise NotImplementedError

    @abstractmethod
    def load_model(self):
        raise NotImplementedError
