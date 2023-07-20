class DBStatementTimeoutException(Exception):
    def __init__(self, message):
        super().__init__("PilotScope:"+message)


class HttpReceiveTimeoutException(Exception):
    def __init__(self, message="HttpService have not receive the required data"):
        super().__init__(message)
        
class DatabaseCrashException(Exception):
    def __init__(self, message="Database crashed. Please start Database mannully"):
        super().__init__(message)
        
class DatabaseStartException(Exception):
    def __init__(self, message="Can't start Database. Recover config and start success"):
        super().__init__(message)