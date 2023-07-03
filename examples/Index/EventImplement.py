from DBController.BaseDBController import BaseDBController
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from PilotEvent import PeriodicDbControllerEvent


class IndexPeriodicDbControllerEvent(PeriodicDbControllerEvent):

    def _custom_update(self, db_controller: BaseDBController, training_data_manager: PilotTrainDataManager):
        pass
