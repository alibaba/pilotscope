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
    print("Terminate pilotscope either at the end of the program or in case of an exception.")
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



# Modified from https://github.com/pfl-cs/ALECE/blob/main/src/benchmark/p_error_cmp.py
def plan_to_pg_hint(plan_obj, scan_hint_list, join_hint_list):
    FEATURE_LIST = ['Node Type', 'Startup Cost',
                    'Total Cost', 'Plan Rows', 'Plan Width']
    LABEL_LIST = ['Actual Startup Time', 'Actual Total Time', 'Actual Self Time']

    UNKNOWN_OP_TYPE = "Unknown"
    SCAN_TYPES = ["Seq Scan", "Index Scan", "Index Only Scan", 'Bitmap Heap Scan']
    JOIN_TYPES = ["Nested Loop", "Hash Join", "Merge Join"]
    OTHER_TYPES = ['Bitmap Index Scan']
    OP_TYPES = [UNKNOWN_OP_TYPE, "Hash", "Materialize", "Sort", "Aggregate", "Incremental Sort", "Limit"] \
               + SCAN_TYPES + JOIN_TYPES + OTHER_TYPES

    node_type = plan_obj['Node Type']
    tables = None
    if "Plans" in plan_obj:
        children = plan_obj["Plans"]

        left_tables = []
        right_tables = []
        if len(children) == 2:
            left_tables = plan_to_pg_hint(children[0], scan_hint_list, join_hint_list)
            right_tables = plan_to_pg_hint(children[1], scan_hint_list, join_hint_list)
            tables = (left_tables, right_tables)
        else:
            assert len(children) == 1
            left_tables = plan_to_pg_hint(children[0], scan_hint_list, join_hint_list)
            tables = left_tables

        if node_type in JOIN_TYPES:
            join_hint_list.append(node_type.replace(" ", "").replace("Nested", "Nest") + "(" + \
                                  str(tables).replace("'", "").replace(",", " ").replace("(", "").replace(")",
                                                                                                          "") + ")")

        if node_type == "Bitmap Heap Scan":
            assert 'Alias' in plan_obj
            assert len(left_tables) == 0 and len(right_tables) == 0
            assert len(children) == 1
            bitmap_idx_scan = children[0]
            index_name = None
            if "Index Name" in bitmap_idx_scan:
                index_name = bitmap_idx_scan["Index Name"]

            table_name = plan_obj['Alias']
            tables = table_name
            scan_hint_list.append("BitmapScan(" + table_name + ("" if index_name is None else " " + index_name) + ")")


    else:
        if node_type == "Bitmap Index Scan":
            return []

        assert node_type in SCAN_TYPES
        assert 'Alias' in plan_obj
        index_name = None
        if "Index Name" in plan_obj:
            index_name = plan_obj["Index Name"]
        table_name = plan_obj['Alias']
        tables = table_name
        scan_hint_list.append(
            node_type.replace(" ", "") + "(" + table_name + ("" if index_name is None else " " + index_name) + ")")

    return tables


def get_pg_hints(plan_obj):
    scan_hint_list, join_hint_list = [], []
    tables = plan_to_pg_hint(plan_obj["Plan"], scan_hint_list, join_hint_list)
    hint_str = "/*+\n"
    hint_str += "\n".join(scan_hint_list) + "\n"
    hint_str += "\n".join(join_hint_list) + "\n"
    hint_str += "Leading(" + str(tables).replace("'", "").replace(",", " ") + ")\n"
    hint_str += "*/\n"
    return hint_str