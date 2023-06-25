import json

from PilotSysConfig import PilotSysConfig


class PilotCommentCreator:

    def __init__(self, anchor_params: dict = None, enable_terminate_flag=True):
        self.anchor_params = {} if anchor_params is None else anchor_params
        self.enable_terminate_flag = enable_terminate_flag
        self.other = {}

    def add_anchor_params(self, anchor_params: dict):
        self.anchor_params.update(anchor_params)

    def enable_terminate(self, enable):
        self.enable_terminate_flag = enable

    def add_params(self, key_2_value: dict):
        self.other.update(key_2_value)

    def create_comment(self):
        res = {
            PilotSysConfig.ANCHOR_TRANS_JSON_KEY: self.anchor_params,
            "enableTerminate": self.enable_terminate_flag
        }
        res.update(self.other)
        return "/*pilotscope {} pilotscope*/".format(json.dumps(res))
