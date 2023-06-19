import threading
from abc import ABC, abstractmethod
from DataFetcher.BaseDataFetcher import DataFetcher
from PilotConfig import PilotConfig

from Server.Server import ServerManager
from common.Thread import ValueThread


class HttpDataFetcher(DataFetcher):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__(config)
        self.port = None
        self.collect_data_thread = None
        self.url = config.pilotscope_core_url

    def prepare_to_receive_data(self):
        # start a http server in another thread for collecting the extra data sent from database
        self.port = self.config.http_port
        self.collect_data_thread = ValueThread(target=ServerManager.start_server_once_request, args=(
            self.url,
            self.port,
            self.config.once_request_timeout
        ))
        self.collect_data_thread.start()

    def get_additional_info(self) -> dict:
        return {"port": self.port, "url": self.url}

    def wait_until_get_result(self) -> str:
        return self.collect_data_thread.join()

    def stop(self):
        pass
