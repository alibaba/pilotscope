def load_sql(file):
    with open(file) as f:
        sqls = f.readlines()
        return sqls
