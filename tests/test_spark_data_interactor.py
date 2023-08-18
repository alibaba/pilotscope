import unittest

from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import SparkConfig
from pilotscope.DBController.SparkSQLController import SparkSQLController, SparkConfig, SparkSQLDataSourceEnum
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.Factory.DBControllerFectory import DBControllerFactory


class MyTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.config = SparkConfig(
            app_name="testDataInteractor",
            master_url="local[*]"
        )
        self.config.set_datasource(
            SparkSQLDataSourceEnum.POSTGRESQL,
            host='localhost',
            db='stats_tiny',
            user='postgres',
            pwd='postgres'
        )
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.executor.memory": "20g",
            "spark.sql.cbo.enabled":True,
            "spark.sql.cbo.joinReorder.enabled":True
        })
        self.config.set_db_type(DatabaseEnum.SPARK)

        self.db_controller: SparkSQLController = DBControllerFactory.get_db_controller(self.config)

        self.data_interactor = PilotDataInteractor(self.config, self.db_controller)
        self.sql = "select * from badges limit 10" 
        self.sql2 = "select count(*) from badges as b, posts as p where b.userid = p.owneruserid  AND p.posttypeid=2  AND p.score>=0  AND p.score<=20  AND p.commentcount<=12;"
        self.sql3 = "SELECT p.Id, pl.PostId FROM posts as p, postlinks as pl, " + \
            " posthistory as ph WHERE p.Id = pl.PostId AND pl.PostId = ph.PostId AND " + \
            "p.CreationDate>='2010-07-19 20:08:37' AND " + \
            "ph.CreationDate>='2010-07-20 00:30:00' AND p.Score < 50;"
        self.sql_timestamp = "SELECT p.Id, pl.PostId FROM posts as p, postlinks as pl, " + \
            " posthistory as ph WHERE p.Id = pl.PostId AND pl.PostId = ph.PostId AND " + \
            "p.CreationDate>=1279570117 AND " + \
            "ph.CreationDate>=1279585800 AND p.Score < 50;"
        self.sql4 = "SELECT p.Id, pl.PostId FROM badges as b, posts as p, postlinks as pl, " + \
            " posthistory as ph WHERE b.userid = p.owneruserid AND p.Id = pl.PostId AND pl.PostId = ph.PostId;" 

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
        result = self.data_interactor.execute(self.sql4)
        print("result2:\n", result)

    def test_pull_physical_plan(self):
        self.data_interactor.pull_physical_plan()
        result = self.data_interactor.execute(self.sql)
        print(result)

    def test_pull_logical_plan(self):
        self.data_interactor.pull_logical_plan()
        result = self.data_interactor.execute(self.sql)
        print(result)

    # return none
    def test_pull_buffercache(self):
        self.data_interactor.pull_buffercache()
        result = self.data_interactor.execute(self.sql4)
        print(result)

    def test_pull_record(self):
        self.data_interactor.pull_record()
        result = self.data_interactor.execute(self.sql2)
        print(result)

    def test_push_card(self):
        subquery_2_value = {
            "SELECT COUNT(*) FROM posts AS p WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) " : 1234,
            "SELECT COUNT(*) FROM postlinks AS pl WHERE (pl.PostId IS NOT NULL) " : 2345,
            "SELECT COUNT(*) FROM posthistory AS ph WHERE (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) " : 3456,
            "SELECT COUNT(*) FROM posts AS p, postlinks AS pl WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) AND  (pl.PostId IS NOT NULL) AND  (p.Id = pl.PostId) " : 4567,
            "SELECT COUNT(*) FROM postlinks AS pl, posthistory AS ph WHERE (pl.PostId IS NOT NULL) AND  (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) AND  (pl.PostId = ph.PostId) " : 5678
        }
        self.data_interactor.push_card(subquery_2_value)
        result = self.data_interactor.execute(self.sql_timestamp)
        print(result)

    def test_push_card_pull_physical_plan(self):
        self.data_interactor.pull_subquery_card()
        self.data_interactor.pull_physical_plan()
        result1 = self.data_interactor.execute(self.sql_timestamp)
        print("origin physical plan:\n", result1.physical_plan)
        subquery_2_value = {
            "SELECT COUNT(*) FROM posts AS p WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) " : 11,
            "SELECT COUNT(*) FROM postlinks AS pl WHERE (pl.PostId IS NOT NULL) " : 22,
            "SELECT COUNT(*) FROM posthistory AS ph WHERE (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) " : 33,
            "SELECT COUNT(*) FROM posts AS p, postlinks AS pl WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) AND  (pl.PostId IS NOT NULL) AND  (p.Id = pl.PostId) " : 48,
            "SELECT COUNT(*) FROM postlinks AS pl, posthistory AS ph WHERE (pl.PostId IS NOT NULL) AND  (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) AND  (pl.PostId = ph.PostId) " : 53,
        }
        self.data_interactor.push_card(subquery_2_value)
        self.data_interactor.pull_physical_plan()
        result2 = self.data_interactor.execute(self.sql_timestamp)
        print("replaced physical plan:\n", result2.physical_plan)
        print(result1.physical_plan == result2.physical_plan)

    def test_push_card_pull_logical_plan(self):
        self.data_interactor.pull_subquery_card()
        self.data_interactor.pull_logical_plan()
        result1 = self.data_interactor.execute(self.sql_timestamp)
        print("origin logical plan:\n", result1.logical_plan)
        subquery_2_value = {
            "SELECT COUNT(*) FROM posts AS p WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) " : 11,
            "SELECT COUNT(*) FROM postlinks AS pl WHERE (pl.PostId IS NOT NULL) " : 22,
            "SELECT COUNT(*) FROM posthistory AS ph WHERE (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) " : 33,
            "SELECT COUNT(*) FROM posts AS p, postlinks AS pl WHERE ((((p.CreationDate IS NOT NULL) AND (p.Score IS NOT NULL)) AND ((p.CreationDate >= 1279570117) AND (p.Score < 50))) AND (p.Id IS NOT NULL)) AND  (pl.PostId IS NOT NULL) AND  (p.Id = pl.PostId) " : 48,
            "SELECT COUNT(*) FROM postlinks AS pl, posthistory AS ph WHERE (pl.PostId IS NOT NULL) AND  (((ph.CreationDate IS NOT NULL) AND (ph.CreationDate >= 1279585800)) AND (ph.PostId IS NOT NULL)) AND  (pl.PostId = ph.PostId) " : 53,
        }
        self.data_interactor.push_card(subquery_2_value)
        self.data_interactor.pull_logical_plan()
        result2 = self.data_interactor.execute(self.sql_timestamp)
        print("replaced logical plan:\n", result2.logical_plan)
        print(result1.logical_plan == result2.logical_plan)


if __name__ == '__main__':
    unittest.main()