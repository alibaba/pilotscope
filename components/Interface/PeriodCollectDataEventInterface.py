from abc import ABC, abstractmethod


class PeriodCollectDataEventInterface(ABC):
    @abstractmethod
    def get_table_name(self):
        pass

    @abstractmethod
    def collect(self) -> dict:
        pass


class ContinuousCollectDataEventInterface(ABC):
    @abstractmethod
    def get_table_name(self):
        pass

    @abstractmethod
    def has_next(self):
        pass

    @abstractmethod
    def next(self) -> dict:
        pass
