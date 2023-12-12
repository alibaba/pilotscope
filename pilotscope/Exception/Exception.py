class DBStatementTimeoutException(Exception):
    def __init__(self, message):
        super().__init__("PilotScope:" + message)


class InteractorReceiveTimeoutException(Exception):
    def __init__(self, message="InteractorReceive have not receive the data in the specified timeout"):
        super().__init__(message)


class DatabaseCrashException(Exception):
    def __init__(self, message="Database crashed. Please start Database manually"):
        super().__init__(message)


class DatabaseStartException(Exception):
    def __init__(self, message="Can't start Database. Recover config and start success"):
        super().__init__(message)

class PilotScopeInternalError(Exception):
    def __init__(self, message=""):
        super().__init__("An internal error of pilotscope has occurred. Please submit an issue to contact us for a fix. Error info is: "+message)