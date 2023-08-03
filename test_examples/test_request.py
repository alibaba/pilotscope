import unittest
import requests
import json
from urllib3.exceptions import InsecureRequestWarning
from urllib3 import disable_warnings


class MyTestCase(unittest.TestCase):
    def test_send(self):
        url = " http://localhost:54523"  # 指定 API 地址
        data = {"physical_plan": "value1", "logical_plan": "value2"}  # 指定要发送的 JSON 数据

        # 将 Python 对象转换为 JSON 字符串
        json_data = json.dumps(data)

        # 设置请求头，指定发送的数据类型为 JSON
        headers = {'Content-Type': 'application/json'}
        disable_warnings(InsecureRequestWarning)

        # 发送 POST 请求并将 JSON 数据发送给服务器
        response = requests.post(url, data=json_data, headers=headers, verify=False)

        # 打印服务器返回的响应结果
        print(response.text)


if __name__ == '__main__':
    unittest.main()
