from abc import ABC, abstractmethod


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None

    def save_model(self):
        raise NotImplementedError

    def load_model(self):
        raise NotImplementedError
