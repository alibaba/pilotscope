import unittest
from typing import List

from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.PilotTransData import PilotTransData
from pilotscope.DBController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
import sys

sys.path.append("../..")
from algorithm_examples.utils import load_test_sql
from sqlglot import errors, parse_one


class MyTestCase(unittest.TestCase):

    def setUp(self):
        self.config = PostgreSQLConfig()

    def _check_workload(self, sqls):
        for i, sql in enumerate(sqls):
            self.data_interactor.pull_subquery_card()
            result: PilotTransData = self.data_interactor.execute(sql)
            subquery_2_card = result.subquery_2_card
            self.assertFalse(subquery_2_card is None or len(subquery_2_card) == 0)
            print(f"[{i + 1}/{len(sqls)}] [Test SQL] ", sql)
            for sq, card in subquery_2_card.items():
                try:
                    parse_one(sq)
                except Exception as e:
                    print("\tParse ERROR")
                    self.fail(e)
            print(f"SQ Num: {len(subquery_2_card)}")

    def test_job(self):
        self.config.db = "imdb_tiny"
        self.data_interactor = PilotDataInteractor(self.config)
        sqls = load_test_sql("imdb")[56:]
        self._check_workload(sqls)

    def test_stats_ceb(self):
        self.config.db = "stats_tiny"
        self.data_interactor = PilotDataInteractor(self.config)
        sqls = load_test_sql("stats_tiny")
        self._check_workload(sqls)


if __name__ == '__main__':
    unittest.main()
