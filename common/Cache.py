import os

import joblib

from PilotSysConfig import PilotSysConfig


class Cache:
    def __init__(self, name, directory=PilotSysConfig.PILOT_MODEL_DATA_BASE, enable=True):
        """

        :param name: distinguish the different cache
        :param directory:
        :param enable: whether enable cache
        """
        super().__init__()
        self.directory = directory
        self.enable = enable
        self.name = name

    def save(self, target):
        if self.enable:
            file = self._get_absolute_path()
            key = self.get_identifier()
            joblib.dump([key, target], file)

    def read(self):
        if not self.enable:
            raise RuntimeError
        file = self._get_absolute_path()
        if not self.exist():
            raise RuntimeError("File do not exist")
        res = joblib.load(file)
        if res[0] != self.get_identifier():
            raise RuntimeError("identical file name but identifier is not same")
        return res[1]

    def exist(self):
        if not self.enable:
            return False
        file = self._get_absolute_path()
        if not os.path.exists(file):
            return False
        return True

    def get_file_name(self):
        return self.name

    def get_identifier(self):
        return ""

    def _get_absolute_path(self):
        return os.path.join(self.directory, self.get_file_name())
