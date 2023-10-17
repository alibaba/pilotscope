from pilotscope.DBInteractor.HttpInteractorReceiver import HttpInteractorReceiver
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DataFetchMethodEnum


class InteractorReceiverFactory:
    @staticmethod
    def get_data_fetcher(config: PilotConfig):
        if config.data_fetch_method == DataFetchMethodEnum.HTTP:
            return HttpInteractorReceiver(config)
        else:
            raise RuntimeError()
