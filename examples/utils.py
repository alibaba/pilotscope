def load_sql(file):
    with open(file) as f:
        sqls = f.readlines()
        return sqls


def scale_card(subquery_2_card: dict, factor):
    res = {}
    for key, value in subquery_2_card.items():
        res[key] = value * factor
    return res
