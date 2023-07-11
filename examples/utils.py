from DBController.BaseDBController import BaseDBController
from common.TimeStatistic import TimeStatistic


def load_training_sql(db):
    if db == "stats":
        return load_sql("../examples/stats_train.txt")
    elif db == "imdb":
        return load_sql("../examples/job_train.txt")
    else:
        raise NotImplementedError


def load_test_sql(db):
    if db == "stats":
        return load_sql("../examples/stats_test.txt")
    elif db == "imdb":
        return load_sql("../examples/job_test.txt")
    else:
        raise NotImplementedError


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


def recover_stats_index(db_controller: BaseDBController):
    db_controller.drop_all_indexes()
    db_controller.execute("create index idx_posts_owneruserid on posts using btree(owneruserid);")
    db_controller.execute("create index  idx_posts_lasteditoruserid on posts using btree(lasteditoruserid);")
    db_controller.execute("create index idx_postlinks_relatedpostid on postLinks using btree(relatedpostid);")
    db_controller.execute("create index idx_postlinks_postid on postLinks using btree(postid);")
    db_controller.execute("create index idx_posthistory_postid on postHistory using btree(postid);")
    db_controller.execute("create index idx_posthistory_userid on postHistory using btree(userid);")
    db_controller.execute("create index idx_comments_postid on comments using btree(postid);")
    db_controller.execute("create index idx_comments_userid on comments using btree(userid);")
    db_controller.execute("create index idx_votes_userid on votes using btree(userid);")
    db_controller.execute("create index idx_votes_postid on votes using btree(postid);")
    db_controller.execute("create index idx_badges_userid on badges using btree(userid);")
    db_controller.execute("create index idx_tags_excerptpostid on tags using btree(excerptpostid);")
