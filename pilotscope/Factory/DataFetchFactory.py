from pilotscope.DataFetcher.HttpDataFetcher import HttpDataFetcher
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DataFetchMethodEnum


class DataFetchFactory:
    @staticmethod
    def get_data_fetcher(config: PilotConfig):
        if config.data_fetch_method == DataFetchMethodEnum.HTTP:
            return HttpDataFetcher(config)
        else:
            raise RuntimeError()
