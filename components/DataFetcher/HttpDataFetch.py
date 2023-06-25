import threading
from abc import ABC, abstractmethod
import socket
from DataFetcher.BaseDataFetcher import DataFetcher
from PilotConfig import PilotConfig

from Server.Server import ServerManager
from common.Thread import ValueThread


class HttpDataFetcher(DataFetcher):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__(config)
        self.port = self.get_free_port()
        self.url = config.pilotscope_core_url
        self.collect_data_thread = None
        self.server = ServerManager()
        self.server.start_server(self.url, self.port)

    def prepare_to_receive_data(self):
        # start a http server in another thread for collecting the extra data sent from database
        # must have ,
        self.collect_data_thread = ValueThread(target=self.server.receive_once_data, name="http_receive_once_data",
                                               args=(self.config.once_request_timeout,))

        self.collect_data_thread.daemon = True
        self.collect_data_thread.start()

    def get_additional_info(self) -> dict:
        return {"port": self.port, "url": self.url}

    def wait_until_get_result(self) -> str:
        return self.collect_data_thread.join()

    def stop(self):
        pass

    def get_free_port(self):
        sock = socket.socket()
        sock.bind(('', 0))
        port = sock.getsockname()[1]
        sock.close()
        return port

    def __del__(self):
        self.server.stop_server()
