import threading
from abc import ABC, abstractmethod
import socket
from DataFetcher.BaseDataFetcher import DataFetcher
from PilotConfig import PilotConfig

from Server.Server import ServerManager
from common.Thread import ValueThread
from common.Util import singleton


@singleton
class HttpDataFetcher(DataFetcher):

    def __init__(self, config: PilotConfig) -> None:
        super().__init__(config)
        self.port = self.get_free_port()
        self.url = config.pilotscope_core_url
        self.server = ServerManager(self.url, self.port)
        self.timeout = self.config.once_request_timeout

    def get_additional_info(self) -> dict:
        return {"port": self.port, "url": self.url}

    def wait_until_get_data(self) -> str:
        tid = str(threading.get_ident())
        # print("tid is {}".format(tid))
        return self.server.wait_until_get_data(self.timeout, tid)

    def get_free_port(self):
        sock = socket.socket()
        sock.bind(('', 0))
        port = sock.getsockname()[1]
        sock.close()
        return port
