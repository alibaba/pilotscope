import unittest

from pilotscope.DBController.SparkSQLController import SparkConfig, SparkSQLDataSourceEnum
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Exception.Exception import PilotScopeNotSupportedOperationException


class MyTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.config = SparkConfig(
            app_name="testDataInteractor",
            master_url="local[*]2"
        )
        self.config.use_postgresql_datasource(
            db_host='localhost',
            db_port="5432",
            db_user='postgres',
            db_user_pwd='postgres',
            db='stats_tiny',
        )
        self.config.set_spark_session_config({
            "spark.executor.memory": "20g"
        })
        self.config.enable_cardinality_estimation()
        self.data_interactor = PilotDataInteractor(self.config)
        self.sql = "select * from badges limit 10"
        self.sql2 = "select count(*) from badges as b, posts as p where b.userid = p.owneruserid  AND p.posttypeid=2  AND p.score>=0  AND p.score<=20  AND p.commentcount<=12;"
        self.sql_timestamp = "SELECT p.Id, pl.PostId FROM posts as p, postlinks as pl, " + \
                             " posthistory as ph WHERE p.Id = pl.PostId AND pl.PostId = ph.PostId AND " + \
                             "p.CreationDate>=1279570117 AND " + \
                             "ph.CreationDate>=1279585800 AND p.Score < 50;"
        self.sql3 = "SELECT p.Id, pl.PostId FROM badges as b, posts as p, postlinks as pl, " + \
                    " posthistory as ph WHERE b.userid = p.owneruserid AND p.Id = pl.PostId AND pl.PostId = ph.PostId;"

        self.sql_timestamp_subquery_2_value = {
            'SELECT COUNT(*) FROM posts AS p WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) ': 11000.0,
            'SELECT COUNT(*) FROM postlinks AS pl WHERE (pl.PostId IS NOT NULL) ': 22000.0,
            'SELECT COUNT(*) FROM posthistory AS ph WHERE (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) ': 33000.0,
            'SELECT COUNT(*) FROM posts AS p, postlinks AS pl WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) AND  (pl.PostId IS NOT NULL) AND  (p.Id = pl.PostId) ': 48000.0,
            'SELECT COUNT(*) FROM postlinks AS pl, posthistory AS ph WHERE (pl.PostId IS NOT NULL) AND  (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) AND  (pl.PostId = ph.PostId) ': 53000.0,
            'SELECT COUNT(*) FROM postlinks AS pl, posthistory AS ph, posts AS p WHERE (pl.PostId IS NOT NULL) AND  (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) AND  ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) AND  (p.Id = pl.PostId) AND  (pl.PostId = ph.PostId) ': 115.0
        }

    def test_pull_execution_time(self):
        self.data_interactor.pull_execution_time()
        result = self.data_interactor.execute(self.sql)
        print(result)

    def test_pull_subquery_card(self):
        # analyze all tables for the first time
        self.data_interactor.pull_subquery_card()
        result = self.data_interactor.execute(self.sql_timestamp)
        print("result1:\n", result)

        # do not need to analyze tables
        self.data_interactor.pull_subquery_card()
        result = self.data_interactor.execute(self.sql3)
        print("result2:\n", result)

    def test_pull_physical_plan(self):
        self.data_interactor.pull_physical_plan()
        result = self.data_interactor.execute(self.sql)
        print(result)

    def test_pull_buffercache(self):
        self.data_interactor.pull_buffercache()
        try:
            self.data_interactor.execute(self.sql3)
        except PilotScopeNotSupportedOperationException:
            pass

    def test_pull_record(self):
        self.data_interactor.pull_record()
        result = self.data_interactor.execute(self.sql_timestamp)
        print(result)

    def test_card_est(self):
        self.data_interactor.pull_subquery_card()
        self.data_interactor.pull_physical_plan()
        result1 = self.data_interactor.execute(self.sql_timestamp)

        self.data_interactor.push_card(result1.subquery_2_card)
        self.data_interactor.pull_physical_plan()
        result2 = self.data_interactor.execute(self.sql_timestamp)
        self.assertTrue(result1.physical_plan == result2.physical_plan)

        self.data_interactor.push_card(self.sql_timestamp_subquery_2_value)
        self.data_interactor.pull_physical_plan()
        result3 = self.data_interactor.execute(self.sql_timestamp)
        self.assertFalse(result1.physical_plan == result3.physical_plan)

    def test_push_card(self):
        self.data_interactor.push_card(self.sql_timestamp_subquery_2_value)
        result = self.data_interactor.execute(self.sql_timestamp)
        print(result)

    def test_push_card_and_pull_time(self):
        self.data_interactor.push_card(self.sql_timestamp_subquery_2_value)
        self.data_interactor.pull_execution_time()
        result = self.data_interactor.execute(self.sql_timestamp)
        print(result)

    def test_pull_record_and_time(self):
        self.data_interactor.pull_record()
        self.data_interactor.pull_execution_time()
        result = self.data_interactor.execute(self.sql_timestamp)
        print(result)

    def test_push_card_pull_physical_plan_and_time(self):
        self.data_interactor.pull_subquery_card()
        self.data_interactor.pull_physical_plan()
        self.data_interactor.pull_execution_time()
        result1 = self.data_interactor.execute(self.sql_timestamp)
        print("origin physical plan:\n", result1.physical_plan)
        self.data_interactor.push_card(self.sql_timestamp_subquery_2_value)
        self.data_interactor.pull_physical_plan()
        self.data_interactor.pull_execution_time()
        result2 = self.data_interactor.execute(self.sql_timestamp)
        print("replaced physical plan:\n", result2.physical_plan)
        self.assertFalse(result1.physical_plan == result2.physical_plan)


if __name__ == '__main__':
    unittest.main()
