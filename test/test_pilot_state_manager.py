import unittest
from typing import List

from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum
from PilotTransData import PilotTransData
from common.Index import Index
from common.Util import _accumulate_cost
from examples.utils import load_test_sql


class MyTestCase(unittest.TestCase):

    def setUp(self):
        self.config = PilotConfig()
        self.config.db = "stats"
        self.config.set_db_type(DatabaseEnum.POSTGRESQL)
        self.state_manager = PilotStateManager(self.config)
        self.table = "badges"
        self.indexable_column = "date"
        self.sql = "select * from badges limit 1"
        self.index_sql = "select date from badges where date='2014-09-14 02:31:28'"

    def test_fetch_execution_time(self):
        self.state_manager.fetch_execution_time()
        result = self.state_manager.execute(self.sql)
        self.assertFalse(result.execution_time is None)

    def test_fetch_physical_plan(self):
        self.state_manager.fetch_physical_plan()
        result: PilotTransData = self.state_manager.execute(self.sql)
        self.assertFalse(result.physical_plan is None)

    def test_fetch_subquery_card(self):
        self.state_manager.fetch_subquery_card()
        result: PilotTransData = self.state_manager.execute(self.sql)
        self.assertFalse(result.subquery_2_card is None or len(result.subquery_2_card) == 0)
        print(result)

    def test_fetch_estimated_cost(self):
        self.state_manager.fetch_estimated_cost()
        result: PilotTransData = self.state_manager.execute(self.sql)
        self.assertFalse(result.estimated_cost is None)
        print(result)

    def test_index_single(self):
        sql = self.index_sql
        index_name = "test_index"

        index = Index([self.indexable_column], self.table, index_name=index_name)
        self.state_manager.set_index([index], drop_other=True)
        self.state_manager.fetch_estimated_cost()
        res = self.state_manager.execute(sql)
        index_cost = res.estimated_cost

        self.state_manager.fetch_estimated_cost()
        res = self.state_manager.execute(sql)
        origin_cost = res.estimated_cost
        print("index_cost is {}, origin_cost is {}".format(index_cost, origin_cost))
        self.assertFalse(abs(origin_cost - index_cost) < 100)

    def test_index_batch(self):
        sqls = ["select date from badges where date='2014-09-14 02:31:28'",
                "select date from badges where date='2014-09-14 02:31:28'",
                "select date from badges where date='2014-09-14 02:31:28'"]
        index_name = "test_index_batch"

        index = Index([self.indexable_column], self.table, index_name=index_name)
        self.state_manager.set_index([index], drop_other=True)
        self.state_manager.fetch_estimated_cost()
        datas: List[PilotTransData] = self.state_manager.execute_batch(sqls)
        index_cost = _accumulate_cost(datas)

        self.state_manager.fetch_estimated_cost()
        datas = self.state_manager.execute_batch(sqls)
        origin_cost = _accumulate_cost(datas)
        print("index_cost is {}, origin_cost is {}".format(index_cost, origin_cost))
        self.assertFalse(abs(origin_cost - index_cost) < 100)

    def test_(self):
        sqls = load_test_sql(self.config.db)[0:10]
        self.state_manager.reset()
        self.state_manager.fetch_estimated_cost()
        datas = self.state_manager.execute_parallel(sqls, is_reset=True)
        pass


if __name__ == '__main__':
    unittest.main()
