import json
from concurrent.futures import Future

from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler

all_https = []


def is_number(value):
    try:
        value = float(value)
        return True
    except Exception as e:
        return False


def extract_anchor_handlers(anchor_2_handlers: dict, is_fetch_anchor=True):
    res = {}
    from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler

    target = FetchAnchorHandler if is_fetch_anchor else ReplaceAnchorHandler
    for anchor, handler in anchor_2_handlers.items():
        if isinstance(handler, target):
            res[anchor] = handler
    return res


def extract_handlers(handlers, is_fetch_anchor):
    from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
    target = FetchAnchorHandler if is_fetch_anchor else ReplaceAnchorHandler
    return list(filter(lambda anchor: isinstance(anchor, target), handlers))


def extract_table_data_from_anchor(fetch_anchors, data):
    from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
    column_2_value = {}
    for anchor in fetch_anchors:
        if isinstance(anchor, FetchAnchorHandler):
            anchor.add_data_to_table(column_2_value, data)
        else:
            raise RuntimeError
    return column_2_value


def pilotscope_exit(e=None):
    print("pilotscope occur exception, clearing http service")
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
