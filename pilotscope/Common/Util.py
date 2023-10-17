import json
from concurrent.futures import Future
import warnings
from pilotscope.Anchor.BaseAnchor.BasePushHandler import BasePushHandler

all_https = []


def is_number(value):
    try:
        value = float(value)
        return True
    except Exception as e:
        return False


def extract_anchor_handlers(anchor_2_handlers: dict, is_fetch_anchor=True):
    res = {}
    from pilotscope.Anchor.BaseAnchor.BasePullHandler import BasePullHandler

    target = BasePullHandler if is_fetch_anchor else BasePushHandler
    for anchor, handler in anchor_2_handlers.items():
        if isinstance(handler, target):
            res[anchor] = handler
    return res


def extract_handlers(handlers, extract_pull_anchor):
    from pilotscope.Anchor.BaseAnchor.BasePullHandler import BasePullHandler
    target = BasePullHandler if extract_pull_anchor else BasePushHandler
    return list(filter(lambda anchor: isinstance(anchor, target), handlers))


def pilotscope_exit(e=None):
    print("Exit pilotscope as exiting program or exception.")
    if e is not None:
        print(e)
    for http in all_https:
        http.shutdown()


def singleton(class_):
    instances = {}

    def getinstance(*args, **kwargs):
        if class_ not in instances:
            instances[class_] = class_(*args, **kwargs)
        return instances[class_]

    return getinstance


def _accumulate_cost(datas):
    sum_cost = 0
    for data in datas:
        if data is not None:
            sum_cost += data.estimated_cost
    return sum_cost


def sum_list(values):
    res = 0
    for val in values:
        res += val
    return res


def json_str_to_json_obj(json_data):
    if not isinstance(json_data, dict):
        json_obj = json.loads(json_data)
    else:
        json_obj = json_data
    if type(json_obj) == list:
        assert len(json_obj) == 1
        json_obj = json_obj[0]
        assert type(json_obj) == dict
    return json_obj


def wait_futures_results(futures: list):
    results = []
    for future in futures:
        future: Future = future
        results.append(future.result())
    return results


def deprecated(func):
    def wrapper(*args, **kwargs):
        warnings.warn("This function is deprecated.", DeprecationWarning)
        return func(*args, **kwargs)

    return wrapper
