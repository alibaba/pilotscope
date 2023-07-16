import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__)), "common"))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__)), "components"))

import unittest
from pyspark.sql import SparkSession

class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        
    def test_pyspark_sql_get_subqueries(self):
        spark = SparkSession.builder \
            .appName("Spark SQL basic example") \
            .master("local[*]") \
            .config("spark.some.config.option", "some-value") \
            .config("spark.sql.cbo.enabled", True) \
            .config("spark.sql.cbo.joinReorder.enabled", True) \
            .config("spark.sql.pilotscope.enabled", True) \
            .config("spark.sql.pilotscope.debug.enabled", True) \
            .getOrCreate()

        # Force the execution of the following code to use the given SQLConf instance, 
        #    since we will store the "column reference -> tablename" map into the SQLconf instance.
        #SQLConf.withExistingConf(sqlconf){

        # read csv with the header
        df = spark.read.options(inferSchema = True, delimiter = ",", header = True).csv("dev_data/posts.csv")
        df2 = spark.read.options(inferSchema = True, delimiter = ",", header = True).csv("dev_data/postLinks.csv")
        df3 = spark.read.options(inferSchema = True, delimiter = ",", header = True).csv("dev_data/postHistory_small.csv")
        
        df.registerTempTable("posts")
        df2.registerTempTable("postLinks")
        df3.registerTempTable("postHistory")
        
        spark.catalog.cacheTable("posts") 
        spark.catalog.cacheTable("postLinks") 
        spark.catalog.cacheTable("postHistory") 

        spark.sql("ANALYZE TABLE posts COMPUTE STATISTICS FOR ALL COLUMNS")
        spark.sql("ANALYZE TABLE postLinks COMPUTE STATISTICS FOR ALL COLUMNS")
        spark.sql("ANALYZE TABLE postHistory COMPUTE STATISTICS FOR ALL COLUMNS")

        
        records = spark.sql("/*pilotscope " +
            "{\"anchor\":{\"SUBQUERY_CARD_FETCH_ANCHOR\": {\"enable\": true, \"name\": \"SUBQUERY_CARD_FETCH_ANCHOR\"},\"RECORD_FETCH_ANCHOR\":{\"enable\":true,\"name\":\"RECORD_FETCH_ANCHOR\"}}," +
            "\"port\":9090,\"url\":\"11.164.204.36\",\"enableTerminate\":false,\"tid\":\"1234\"} pilotscope*/ " +
        "SELECT p.Id, pl.PostId FROM posts as p, postLinks as pl, " +
        " postHistory as ph WHERE p.Id = pl.PostId AND pl.PostId = ph.PostId AND " +
        "(p.CreationDate>='2010-07-19 20:08:37') AND " +
        "ph.CreationDate>='2010-07-20 00:30:00' AND p.Score < 50")
        
        records.explain("cost")
        
if __name__ == '__main__':
    unittest.main()
