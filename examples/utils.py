from common.TimeStatistic import TimeStatistic


def load_sql(file):
    with open(file) as f:
        sqls = []
        line = f.readline()
        while line is not None and line != "":
            if "#" in line:
                sqls.append(line.split("#####")[1])
            else:
                sqls.append(line)
            line = f.readline()
        return sqls


def scale_card(subquery_2_card: dict, factor):
    res = {}
    for key, value in subquery_2_card.items():
        res[key] = value * factor
    return res


def compress_anchor_name(name_2_values):
    res = {}
    for name, value in name_2_values.items():
        res[name.split("_")[0]] = value
    return res

def add_remain_time_statistic():
    TimeStatistic.get_sum_data()