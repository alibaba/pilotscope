import collections
import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from time import sleep

from Exception.Exception import HttpReceiveTimeoutException
from common.Thread import ValueThread
from common.Util import all_https, singleton

# class ServerManager:
#     def __init__(self):
#         self.receive_signal = threading.Event()
#         self.httpd = None
#
#     def start_server(self, url, port):
#         server_address = (url, port)
#         self.httpd = HTTPServer(server_address, RequestHandler)
#         self.httpd.signal = self.receive_signal
#         # 在一个线程中启动 HTTP 服务器
#         http_thread = ValueThread(target=self.httpd.serve_forever, name="serve_forever", args=())
#         http_thread.daemon = True
#         http_thread.start()
#         all_https.append(self.httpd)
#
#         # 如果服务器未能处理请求，则永久等待，直到接收到信号
#
#     def stop_server(self):
#         self.httpd.shutdown()
#         # 如果服务器未能处理请求，则永久等待，直到接收到信号
#
#     def receive_once_data(self, timeout):
#         self.httpd.user_data = None
#         self.receive_signal.clear()
#         timeout_stop = not self.receive_signal.wait(timeout)
#
#         receive_data = self.httpd.user_data if not timeout_stop else None
#         return receive_data

data_lock = threading.Condition()
tid_2_lock = {}
tid_2_data = {}


@singleton
class ServerManager:
    def __init__(self, url, port):
        self.url = url
        self.port = port
        self.httpd = None
        self._start_server(url, port)
        print("server url is {}, port is {}".format(url, port))

    def _start_server(self, url, port):
        server_address = (url, port)
        self.httpd = HTTPServer(server_address, RequestHandler)
        # start http server
        http_thread = ValueThread(target=self.httpd.serve_forever, name="serve_forever", args=())
        http_thread.daemon = True
        http_thread.start()
        all_https.append(self.httpd)

    def wait_until_get_data(self, timeout, tid):
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
                timeout_stop = not cond.wait(timeout)

        if timeout_stop:
            raise HttpReceiveTimeoutException()

        return tid_2_data[tid]


class RequestHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        content_length = int(self.headers.get('content-length'))
        data = self.rfile.read(content_length).decode('utf-8')

        with data_lock:
            # receive data
            data = json.loads(data)
            tid = data["tid"]
            tid_2_data[tid] = data

            # release the corresponding thread
            if tid in tid_2_lock:
                cond: threading.Condition = tid_2_lock[tid]
                with cond:
                    cond.notify()

        # 响应 HTTP 请求
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
