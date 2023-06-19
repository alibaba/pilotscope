from abc import ABC, abstractmethod

from Dao.PilotTrainDataManager import PilotTrainDataManager
from PilotConfig import PilotConfig
from PilotModel import PilotModel


class PretrainingEventInterface(ABC):

    def __init__(self, config: PilotConfig, bind_model: PilotModel):
        self.config = config
        self._model: PilotModel = bind_model
        self._train_data_manager = PilotTrainDataManager(config)

    def collect_and_write(self):
        if self._model.is_finished_pretraining:
            return
        column_2_value = self._custom_collect_data()
        table = self._get_table_name()
        self._train_data_manager.save_data(table, column_2_value)

    def train(self):
        if self._model.is_finished_pretraining:
            return
        self._model.model = self._custom_pretrain_model(self._train_data_manager)
        self._model.is_finished_pretraining = True

    @abstractmethod
    def _custom_collect_data(self):
        pass

    @abstractmethod
    def _get_table_name(self):
        pass

    @abstractmethod
    def _custom_pretrain_model(self, train_data_manager: PilotTrainDataManager):
        pass
