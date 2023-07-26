from abc import ABC, abstractmethod

from PilotConfig import PilotConfig

from sqlalchemy import Table, Column, Integer, Float, String, MetaData, select


class DataFetcher(ABC):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__()
        self.config = config

    @abstractmethod
    def get_additional_info(self) -> dict:
        return {}

    @abstractmethod
    def wait_until_get_data(self) -> str:
        pass
