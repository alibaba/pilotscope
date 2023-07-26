from DataFetcher.HttpDataFetch import HttpDataFetcher
from PilotConfig import PilotConfig
from PilotEnum import DataFetchMethodEnum


class DataFetchFactory:
    @staticmethod
    def get_data_fetcher(config: PilotConfig):
        if config.data_fetch_method == DataFetchMethodEnum.HTTP:
            return HttpDataFetcher(config)
        else:
            raise RuntimeError()
