import unittest
from http.server import HTTPServer

from Server.Server import RequestHandler


class MyTestCase(unittest.TestCase):
    def test_something(self):
        url = "localhost"
        port = 54210
        server_address = (url, port)
        httpd = HTTPServer(server_address, RequestHandler)

    def test_thread_local(self):
        import threading

        # 创建线程本地存储
        local_data = threading.local()

        def worker():
            # 在线程本地存储中保存数据
            local_data.value = threading.get_ident()
            print(f"Thread {threading.get_ident()} value = {local_data.value}")

        # 创建多个线程
        threads = []
        for i in range(5):
            t = threading.Thread(target=worker)
            threads.append(t)
            t.start()

        # 等待所有线程执行结束
        for t in threads:
            t.join()


if __name__ == '__main__':
    unittest.main()
