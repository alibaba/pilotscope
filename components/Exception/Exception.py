class DBStatementTimeoutException(Exception):
    def __init__(self, message):
        super().__init__("PilotScope:"+message)


class HttpReceiveTimeoutException(Exception):
    def __init__(self, message="HttpService have not receive the required data"):
        super().__init__(message)
