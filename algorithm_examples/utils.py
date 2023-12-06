import os

from pilotscope.Common.Index import Index
from pilotscope.Common.Util import json_str_to_json_obj
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.Dataset.ImdbDataset import ImdbDataset
from pilotscope.Dataset.StatsDataset import StatsDataset
from pilotscope.Dataset.StatsTinyDataset import StatsTinyDataset
from pilotscope.Dataset.TpcdsDataset import TpcdsDataset
from pilotscope.PilotEnum import DatabaseEnum


def get_path(sql_file):
    my_path = os.path.abspath(__file__)
    return os.path.join(os.path.dirname(my_path), sql_file)


def load_training_sql(db):
    if "stats_tiny" == db.lower():
        return StatsTinyDataset(DatabaseEnum.POSTGRESQL).read_train_sql()
    elif "stats" in db.lower():
        return StatsDataset(DatabaseEnum.POSTGRESQL).read_train_sql()
    elif "imdb" in db:
        return ImdbDataset(DatabaseEnum.POSTGRESQL).read_train_sql()
    elif "tpcds" in db.lower():
        return TpcdsDataset(DatabaseEnum).read_train_sql()
    else:
        raise NotImplementedError


def load_test_sql(db):
    if "stats_tiny" == db.lower():
        return StatsTinyDataset(DatabaseEnum.POSTGRESQL).read_test_sql()
    elif "stats" in db.lower():
        return StatsDataset(DatabaseEnum.POSTGRESQL).read_test_sql()
    elif "imdb" in db:
        return ImdbDataset(DatabaseEnum.POSTGRESQL).read_test_sql()
    elif "tpcds" in db.lower():
        return TpcdsDataset(DatabaseEnum).read_test_sql()
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


def recover_imdb_index(db_controller: BaseDBController):
    queries = [
        'CREATE INDEX "person_id_aka_name" ON "public"."aka_name" USING btree ("person_id");',
        'CREATE INDEX "kind_id_aka_title" ON "public"."aka_title" USING btree ("kind_id");',
        'CREATE INDEX "movie_id_aka_title" ON "public"."aka_title" USING btree ("movie_id");',
        'CREATE INDEX "movie_id_cast_info" ON "public"."cast_info" USING btree ("movie_id");',
        'CREATE INDEX "person_id_cast_info" ON "public"."cast_info" USING btree ("person_id");',
        'CREATE INDEX "person_role_id_cast_info" ON "public"."cast_info" USING btree ("person_role_id");',
        'CREATE INDEX "role_id_cast_info" ON "public"."cast_info" USING btree ("role_id");',
        'CREATE INDEX "movie_id_complete_cast" ON "public"."complete_cast" USING btree ("movie_id");',
        'CREATE INDEX "status_id_complete_cast" ON "public"."complete_cast" USING btree ("status_id");',
        'CREATE INDEX "subject_id_complete_cast" ON "public"."complete_cast" USING btree ("subject_id");',
        'CREATE INDEX "company_id_movie_companies" ON "public"."movie_companies" USING btree ("company_id");',
        'CREATE INDEX "company_type_id_movie_companies" ON "public"."movie_companies" USING btree ("company_type_id");',
        'CREATE INDEX "movie_id_movie_companies" ON "public"."movie_companies" USING btree ("movie_id");',
        'CREATE INDEX "info_type_id_movie_info" ON "public"."movie_info" USING btree ("info_type_id");',
        'CREATE INDEX "movie_id_movie_info" ON "public"."movie_info" USING btree ("movie_id");',
        'CREATE INDEX "info_type_id_movie_info_idx" ON "public"."movie_info_idx" USING btree ("info_type_id");',
        'CREATE INDEX "movie_id_movie_info_idx" ON "public"."movie_info_idx" USING btree ("movie_id");',
        'CREATE INDEX "keyword_id_movie_keyword" ON "public"."movie_keyword" USING btree ("keyword_id");',
        'CREATE INDEX "movie_id_movie_keyword" ON "public"."movie_keyword" USING btree ("movie_id");',
        'CREATE INDEX "link_type_id_movie_link" ON "public"."movie_link" USING btree ("link_type_id");',
        'CREATE INDEX "linked_movie_id_movie_link" ON "public"."movie_link" USING btree ("linked_movie_id");',
        'CREATE INDEX "movie_id_movie_link" ON "public"."movie_link" USING btree ("movie_id");',
        'CREATE INDEX "info_type_id_person_info" ON "public"."person_info" USING btree ("info_type_id");',
        'CREATE INDEX "person_id_person_info" ON "public"."person_info" USING btree ("person_id");',
        'CREATE INDEX "kind_id_title" ON "public"."title" USING btree ("kind_id");'
    ]

    for query in queries:
        db_controller.execute(query)


def to_pilot_index(index):
    columns = [c.name for c in index.columns]
    pilot_index = Index(columns=columns, table=index.table().name, index_name=index.index_idx())
    if hasattr(index, "hypopg_oid"):
        pilot_index.hypopg_oid = index.hypopg_oid
    if hasattr(index, "hypopg_name"):
        pilot_index.hypopg_name = index.hypopg_name
    return pilot_index


def to_tree_json(spark_plan):
    plan = json_str_to_json_obj(spark_plan)
    if "Plan" in plan and isinstance(plan["Plan"], list):
        plan["Plan"], _ = _to_tree_json(plan["Plan"], 0)
    else:
        plan["Plan"], _ = _to_tree_json(plan["inputPlan"], 0)
    return plan


def _to_tree_json(targets, index=0):
    node = targets[index]
    num_children = node["num-children"]

    all_child_node_size = 0
    if num_children == 0:
        # +1 is self
        return node, all_child_node_size + 1

    left_node, left_size = _to_tree_json(targets, index + all_child_node_size + 1)
    node["Plans"] = [left_node]
    all_child_node_size += left_size

    if num_children == 2:
        right_node, right_size = _to_tree_json(targets, index + all_child_node_size + 1)
        node["Plans"].append(right_node)
        all_child_node_size += right_size

    return node, all_child_node_size + 1


def get_spark_table_name_for_scan_node(node: dict):
    node_type = node["class"]
    if "org.apache.spark.sql.execution.columnar.InMemoryTableScanExec" == node_type:
        table = node["relation"][0]["cacheBuilder"]["tableName"]
        assert len(node["relation"]) == 1
    elif "org.apache.spark.sql.execution.RowDataSourceScanExec" == node_type:
        table = node["output"][0][0]["name"]
        assert len(node["output"][0]) == 1
    else:
        raise NotImplementedError
    return table
