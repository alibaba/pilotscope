from abc import ABC, abstractmethod

from pilotscope.PilotConfig import PilotConfig


class InteractorReceiver(ABC):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__()
        self.config = config

    @abstractmethod
    def get_extra_infos_for_trans(self) -> dict:
        return {}

    @abstractmethod
    def block_for_data_from_db(self) -> str:
        pass
