from abc import ABC, abstractmethod

from PilotConfig import PilotConfig

from sqlalchemy import Table, Column, Integer, Float, String, MetaData, select


class DataFetcher(ABC):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__()
        self.config = config

    @abstractmethod
    def prepare_to_receive_data(self):
        pass

    @abstractmethod
    def get_additional_info(self) -> dict:
        return {}

    @abstractmethod
    def wait_until_get_result(self) -> str:
        pass

    @abstractmethod
    def stop(self):
        pass
