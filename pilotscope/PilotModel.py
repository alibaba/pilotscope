from abc import ABC, abstractmethod


class PilotModel(ABC):
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None

    @abstractmethod
    def save_model(self):
        """
        A custom save function for the model. PilotScope will call this function to save the model.
        """
        raise NotImplementedError

    @abstractmethod
    def load_model(self):
        """
        A custom load function for the model. PilotScope will call this function to load the model.
        At the last of this function, you must assign the loaded model to `self.model`.
        """
        raise NotImplementedError
