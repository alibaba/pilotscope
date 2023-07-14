import unittest
import time
from http.server import HTTPServer

from Server.Server import RequestHandler
from examples.utils import load_training_sql


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

    def test2(self):
        filter_sqls = []

        with open("../examples/job_test.txt", "r") as f:
            sqls = f.readlines()

        for sql in sqls:
            if not sql.isascii():
                print('Line contains non-ASCII characters:', sql)
            else:
                filter_sqls.append(sql)
        # with open("../examples/job_train_ascii.txt", "w") as f:
        #     for sql in filter_sqls:
        #         f.write(sql )


if __name__ == '__main__':
    unittest.main()
