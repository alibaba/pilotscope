import socket
from pilotscope.DBInteractor.InteractorReceiver import InteractorReceiver
from pilotscope.PilotConfig import PilotConfig

import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
import time
from pilotscope.Exception.Exception import InteractorReceiveTimeoutException
from pilotscope.PilotEnum import ExperimentTimeEnum
from pilotscope.Common.Thread import ValueThread
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.Common.Util import all_https, singleton

data_lock = threading.Condition()
tid_2_lock = {}
tid_2_data = {}


@singleton
class HttpInteractorReceiver(InteractorReceiver):
    """
    It is used to collect data from all instances of databaseControllers by Http Service.
    The "tid" is used to distinguish the source of data that returned by database connections.
    """

    def __init__(self, config: PilotConfig) -> None:
        super().__init__(config)
        self.timeout = self.config.once_request_timeout
        self.port = self.get_free_port()
        self.url = config.pilotscope_core_host
        self.httpServer = None

        self._start(self.url, self.port)
        print("server url is {}, port is {}".format(self.url, self.port))

    def get_extra_infos_for_trans(self) -> dict:
        return {"port": self.port, "url": self.url}

    def block_for_data_from_db(self) -> str:
        tid = str(threading.get_ident())
        with data_lock:
            if tid in tid_2_data:
                data = tid_2_data[tid]
                tid_2_data.pop(tid)
                return data
            else:
                cond = threading.Condition()
                tid_2_lock[tid] = cond

            # wait to receive data
        with cond:
            if tid not in tid_2_data:
                timeout_stop = not cond.wait(self.timeout)

        if timeout_stop:
            raise InteractorReceiveTimeoutException()

        return tid_2_data[tid]

    def _start(self, url, port):
        server_address = (url, port)
        self.httpServer = HTTPServer(server_address, RequestHandler)

        # start http service for the data collection
        http_thread = ValueThread(target=self.httpServer.serve_forever, name="serve_forever", args=())
        http_thread.daemon = True
        http_thread.start()
        all_https.append(self.httpServer)

    def get_free_port(self):
        sock = socket.socket()
        sock.bind(('', 0))
        port = sock.getsockname()[1]
        sock.close()
        return port


class RequestHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        content_length = int(self.headers.get('content-length'))
        data = self.rfile.read(content_length).decode('utf-8')

        data = json.loads(data)
        cur_time = time.time_ns() / 1000000000.0
        TimeStatistic.add_time(ExperimentTimeEnum.DB_HTTP, float(cur_time - float(data["http_time"])))
        with data_lock:
            # receive data
            tid = data["tid"]
            tid_2_data[tid] = data

            # release the corresponding thread
            if tid in tid_2_lock:
                cond: threading.Condition = tid_2_lock[tid]
                with cond:
                    cond.notify()

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
