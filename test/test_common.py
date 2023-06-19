import unittest
from http.server import HTTPServer

from Server.Server import RequestHandler


class MyTestCase(unittest.TestCase):
    def test_something(self):
        url = "localhost"
        port = 54210
        server_address = (url, port)
        httpd = HTTPServer(server_address, RequestHandler)


if __name__ == '__main__':
    unittest.main()
