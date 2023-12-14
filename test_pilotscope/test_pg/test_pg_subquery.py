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

    def _check_sq(self, sql, results, enable_parameterized_subquery=False):
        self.data_interactor.pull_subquery_card(enable_parameterized_subquery)
        result: PilotTransData = self.data_interactor.execute(sql)
        subquery_2_card = result.subquery_2_card
        self.assertFalse(subquery_2_card is None or len(subquery_2_card) == 0)
        print("[Test SQL] ", sql)
        sqs = []
        for i, (sq, card) in enumerate(subquery_2_card.items()):
            print(f"\tSQ {i+1}: ", sq, card)
            if sq.count("/*") == 1:  # not parameterized path
                sqs.append(sq)
            else:      # parameterized path
                sq = sq.split("; ")[:-2]
                for q in sq:
                    sqs.append(q)

        self.assertEqual(len(sqs), len(results), "The count of subqueries is incorrect.")
        for i, sq in enumerate(sqs):
            try:
                parse_one(sq)
            except Exception as e:
                print("\tParse ERROR", sq)
                self.fail(e)
            result1 = self.db_controller.execute(sq, fetch=True)
            result2 = self.db_controller.execute(results[i], fetch=True)
            self.assertTrue(result1 == result2, f"SQ ERROR, {i+1}: {sq}, {results[i]}")

    def test_contains_string(self):
        print("\n[Test Type String]")
        sql = "select * from company_name as cn where cn.country_code = '[ru]';"
        results = ["select COUNT(*) from company_name as cn where cn.country_code = '[ru]';"]
        self._check_sq(sql, results)
    
    def test_like(self):
        print("\n[Test keyword Like]")
        sql = "select * from cast_info ci where ci.note like '%(voice)%';"
        results = ["select COUNT(*) from cast_info ci where ci.note like '%(voice)%';"]
        self._check_sq(sql, results)
    
    def test_between(self):
        print("\n[Test keyword Between]")
        sql = "select * from title t where t.production_year between 2007 and 2010;"
        results = ["select COUNT(*) from title t where t.production_year between 2007 and 2010;"]
        self._check_sq(sql, results)
    
    def test_in(self):
        print("\n[Test keyword In]")
        sql = "select * from keyword k where k.keyword in ('sequel', 'revenge', 'based-on-novel');"
        results = ["select COUNT(*) from keyword k where k.keyword in ('sequel', 'revenge', 'based-on-novel');"]
        self._check_sq(sql, results)
    
    def test_is_null(self):
        print("\n[Test operation \'is Null\']")
        sql = "select * from movie_companies mc where mc.note is Null;"
        results = ["select COUNT(*) from movie_companies mc where mc.note is Null;"]
        self._check_sq(sql, results)
    
    def test_and_or(self):
        print("\n[Test And OR]")
        sql = "select * from company_name as cn WHERE cn.country_code !='[pl]' and (cn.name like '%Film%' or cn.name like '%Warner%');"
        results = ["select COUNT(*) from company_name as cn WHERE cn.country_code !='[pl]' and (cn.name like '%Film%' or cn.name like '%Warner%');"]
        self._check_sq(sql, results)

    def test_inner_join(self):
        print("\n[Test Inner Join]")
        sql = "select * from title t,movie_keyword mk where t.id=mk.movie_id and mk.keyword_id=117;"
        results = [
            "SELECT COUNT(*) FROM title t;",
            "SELECT COUNT(*) FROM movie_keyword mk WHERE (mk.keyword_id = 117);",
            "SELECT COUNT(*) FROM title t;",
            "SELECT COUNT(DISTINCT mk.movie_id) FROM movie_keyword mk;",
            "SELECT COUNT(*) FROM movie_keyword mk WHERE (mk.keyword_id = 117);",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "SELECT COUNT(*) FROM title t, movie_keyword mk WHERE (t.id = mk.movie_id) AND (mk.keyword_id = 117);",
        ]
        non_param_index = [0,1,6]
        print("-- test normal subquery")
        self._check_sq(sql, [results[i] for i in non_param_index], False)
        print("-- test parameterized subquery")
        self._check_sq(sql, results, True)
    
    def test_left_join(self):
        print("\n[Test Left Join]")
        sql = "select * from title t LEFT JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;"
        results = [
            "SELECT COUNT(*) FROM title t WHERE (t.production_year = 2008);",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "SELECT COUNT(*) FROM title t LEFT JOIN movie_keyword mk ON t.id = mk.movie_id WHERE (t.production_year = 2008);",
        ]
        non_param_index = [0,1,4]
        print("-- test normal subquery")
        self._check_sq(sql, [results[i] for i in non_param_index], False)
        print("-- test parameterized subquery")
        self._check_sq(sql, results, True)
        
    def test_right_join(self):
        print("\n[Test Right Join]")
        sql = "select * from movie_keyword mk Right JOIN title t on t.id=mk.movie_id;"
        results = [
            "SELECT COUNT(*) FROM movie_keyword mk",
            "SELECT COUNT(*) FROM title t;",
            "SELECT COUNT(*) FROM movie_keyword mk",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "select COUNT(*) FROM movie_keyword mk Right JOIN title t ON t.id=mk.movie_id;",
        ]
        non_param_index = [0,1,4]
        print("-- test normal subquery")
        self._check_sq(sql, [results[i] for i in non_param_index], False)
        print("-- test parameterized subquery")
        self._check_sq(sql, results, True)
    
    def test_full_join(self):
        print("\n[Test Full Join]")
        sql = "select * from title t FULL JOIN movie_keyword mk on t.id=mk.movie_id where t.production_year=2008;"
        results = [
            "SELECT COUNT(*) FROM title t WHERE (t.production_year = 2008);",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "select COUNT(*) from title t FULL JOIN movie_keyword mk ON t.id=mk.movie_id where t.production_year=2008;",
        ]
        non_param_index = [0,1,4]
        print("-- test normal subquery")
        self._check_sq(sql, [results[i] for i in non_param_index], False)
        print("-- test parameterized subquery")
        self._check_sq(sql, results, True)
    
    def test_mix_join(self):
        print("\n[Test Mix Join]")
        sql = "select * from movie_companies mc, title t LEFT JOIN movie_keyword mk on t.id=mk.movie_id where t.id=mc.movie_id and t.production_year > 2007;"
        results = [
            "SELECT COUNT(*) FROM movie_companies mc;",
            "SELECT COUNT(*) FROM title t WHERE (t.production_year > 2007);",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(*) FROM movie_companies mc;",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "SELECT COUNT(*) FROM title t WHERE (t.production_year > 2007);",
            "SELECT COUNT(DISTINCT mc.movie_id) FROM movie_companies mc;",
            "SELECT COUNT(*) FROM movie_keyword mk;",
            "SELECT COUNT(DISTINCT t.id) FROM title t;",
            "SELECT COUNT(*) FROM movie_companies mc, title t WHERE (mc.movie_id = t.id) AND (t.production_year > 2007);",
            "SELECT COUNT(*) FROM title t LEFT JOIN movie_keyword mk ON t.id = mk.movie_id WHERE (t.production_year > 2007);",
            "SELECT COUNT(*) FROM movie_companies mc, title t LEFT JOIN movie_keyword mk ON t.id=mk.movie_id WHERE t.id=mc.movie_id AND t.production_year > 2007;",
        ]
        non_param_index = [0,1,2,9,10,11]
        print("-- test normal subquery")
        self._check_sq(sql, [results[i] for i in non_param_index], False)
        print("-- test parameterized subquery")
        self._check_sq(sql, results, True)


if __name__ == '__main__':
    unittest.main()
