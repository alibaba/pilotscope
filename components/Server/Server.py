import socket
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading


class ServerManager:

    @classmethod
    # pylint: disable=no-member
    def start_server_once_request(cls, url, port, timeout):
        signal = threading.Event()
        server_address = (url, port)
        httpd = HTTPServer(server_address, RequestHandler)
        httpd.signal = signal
        # 在一个线程中启动 HTTP 服务器
        http_thread = threading.Thread(target=httpd.serve_forever, args=())
        http_thread.start()
        # 如果服务器未能处理请求，则永久等待，直到接收到信号

        timeout_stop = not signal.wait(timeout=timeout)

        receive_data = httpd.user_data if not timeout_stop else None

        # close
        httpd.shutdown()
        http_thread.join()
        return receive_data


class RequestHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        content_type = self.headers.get('content-type')
        content_length = int(self.headers.get('content-length'))
        data = self.rfile.read(content_length).decode('utf-8')

        # 在这里处理收到的 POST 请求数据
        self.server.user_data = data

        # 响应 HTTP 请求
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')

        # 发送信号
        self.server.signal.set()
