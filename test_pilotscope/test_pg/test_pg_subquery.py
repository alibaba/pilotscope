import unittest

from sqlglot import parse_one

from pilotscope.DBController import PostgreSQLController
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData


class MyTestCase(unittest.TestCase):

    def setUp(self):
        self.config = PostgreSQLConfig()
        self.config.db = "imdb_tiny"
        self.data_interactor = PilotDataInteractor(self.config)
        self.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(self.config)

    def _check_sq(self, sql, results):
        self.data_interactor.pull_subquery_card()
        result: PilotTransData = self.data_interactor.execute(sql)
        subquery_2_card = result.subquery_2_card
        self.assertFalse(subquery_2_card is None or len(subquery_2_card) == 0)
        self.assertEqual(len(subquery_2_card), len(results), "The count of subqueries is incorrect.")
        print("[Test SQL] ", sql)
        for i, (sq, card) in enumerate(subquery_2_card.items()):
            print(f"\tSQ {i + 1}: ", sq, card)
            try:
                parse_one(sq)
            except Exception as e:
                print("\tParse ERROR")
                self.fail(e)
            result1 = self.db_controller.execute(sq, fetch=True)
            # if "count" not in results[i].lower():
            #     results[i] = results[i].replace("*", "COUNT(*)")
            result2 = self.db_controller.execute(results[i], fetch=True)

            if result1 != result2:
                print("\tSQ ERROR")
            # self.assertEqual(result1, result2, "SQ ERROR")
            self.assertTrue(result1 == result2, "SQ ERROR")

    def test_contains_string(self):
        sql = "select * from company_name as cn where cn.country_code = '[ru]';"
        results = ["select COUNT(*) from company_name as cn where cn.country_code = '[ru]';"]
        self._check_sq(sql, results)

    def test_like(self):
        sql = "select * from cast_info ci where ci.note like '%(voice)%';"
        results = ["select COUNT(*) from cast_info ci where ci.note like '%(voice)%';"]
        self._check_sq(sql, results)

    def test_between(self):
        sql = "select * from title t where t.production_year between 2007 and 2010;"
        results = ["select COUNT(*) from title t where t.production_year between 2007 and 2010;"]
        self._check_sq(sql, results)

    def test_in(self):
        sql = "select * from keyword k where k.keyword in ('sequel', 'revenge', 'based-on-novel');"
        results = ["select COUNT(*) from keyword k where k.keyword in ('sequel', 'revenge', 'based-on-novel');"]
        self._check_sq(sql, results)

    def test_is_null(self):
        sql = "select * from movie_companies mc where mc.note is Null;"
        results = ["select COUNT(*) from movie_companies mc where mc.note is Null;"]
        self._check_sq(sql, results)

    def test_and_or(self):
        sql = "select * from company_name as cn WHERE cn.country_code !='[pl]' and (cn.name like '%Film%' or cn.name like '%Warner%');"
        results = [
            "select COUNT(*) from company_name as cn WHERE cn.country_code !='[pl]' and (cn.name like '%Film%' or cn.name like '%Warner%');"]
        self._check_sq(sql, results)

    def test_inner_join(self):
        sql = "select * from title t,movie_keyword mk where t.id=mk.movie_id and mk.keyword_id=117;"
        results = [
            "SELECT COUNT(*) FROM title t;",
            "SELECT COUNT(*) FROM movie_keyword mk WHERE (mk.keyword_id = 117);",
            "select COUNT(*) from title t,movie_keyword mk where t.id=mk.movie_id and mk.keyword_id=117;",
        ]
        self._check_sq(sql, results)

    def test_left_join(self):
        sql = "select * from title t LEFT JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;"
        results = [
            "SELECT COUNT(*) FROM title t WHERE (t.production_year = 2008);",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "select COUNT(*) from title t LEFT JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;",
        ]
        self._check_sq(sql, results)

    def test_right_join(self):
        sql = "select * from movie_keyword mk Right JOIN title t on t.id=mk.movie_id;"
        results = [
            "SELECT COUNT(*) FROM movie_keyword mk",
            "SELECT COUNT(*) FROM title t;",
            "select COUNT(*) from movie_keyword mk Right JOIN title t on t.id=mk.movie_id;",
        ]
        self._check_sq(sql, results)

    def test_full_join(self):
        sql = "select * from title t FULL JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;"
        results = [
            "SELECT COUNT(*) FROM title t WHERE (t.production_year = 2008);",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "select COUNT(*) from title t FULL JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;",
        ]
        self._check_sq(sql, results)


if __name__ == '__main__':
    unittest.main()
