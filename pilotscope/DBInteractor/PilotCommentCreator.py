import json
import threading

from pilotscope.PilotSysConfig import PilotSysConfig


class PilotCommentCreator:

    def __init__(self, anchor_params: dict = None, enable_terminate_flag=True, enable_receive_pilot_data=True, extra_comment = None):
        self.anchor_params = {} if anchor_params is None else anchor_params
        self.enable_terminate_flag = enable_terminate_flag
        self.enable_receive_pilot_data_flag = enable_receive_pilot_data
        self.other = {}
        self.extra_comment = extra_comment

    def add_anchor_params(self, anchor_params: dict):
        self.anchor_params.update(anchor_params)

    def enable_terminate(self, enable):
        self.enable_terminate_flag = enable

    # todo: remove
    def enable_receive_pilot_data(self, enable):
        self.enable_receive_pilot_data_flag = enable

    def add_params(self, key_2_value: dict):
        self.other.update(key_2_value)

    def create_comment(self):
        res = {
            PilotSysConfig.ANCHOR_TRANS_JSON_KEY: self.anchor_params,
            "enableTerminate": self.enable_terminate_flag,
            "enableReceiveData": self.enable_receive_pilot_data_flag
        }
        res.update(self.other)
        res.update({"tid": str(threading.get_ident())})
        if self.extra_comment is None:
            return "/*pilotscope {} pilotscope*/".format(json.dumps(res))
        else:
            return "{} /*pilotscope {} pilotscope*/".format(self.extra_comment, json.dumps(res))

    def create_comment_sql(self, sql):
        return self.connect_comment_and_sql(self.create_comment(), sql)

    def connect_comment_and_sql(self, comment, sql):
        return "{} {}".format(comment, sql)
