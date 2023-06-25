import json


def connect_comment_and_sql(comment, sql):
    return "{} {}".format(comment, sql)


def create_comment(anchor_params: dict):
    return "/*pilotscope {} pilotscope*/".format(json.dumps(anchor_params))


def add_terminate_flag_to_comment(anchor_params: dict, enable):
    anchor_params["enableTerminate"] = enable
