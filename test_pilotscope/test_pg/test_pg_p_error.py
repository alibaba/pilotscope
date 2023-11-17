import unittest
import random

from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData
from pilotscope.Common.CardMetricCalc import p_error_calc

class MyTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.data_interactor = PilotDataInteractor(cls.config)
        cls.sql = "select count(*) from comments as c, posts as p, votes as v, badges as b, users as u where u.id =c.userid and c.userid = p.owneruserid and p.owneruserid = v.userid and v.userid = b.userid and c.score=1 and p.score>=-2 and p.score<=23 and p.viewcount<=2432 and p.commentcount=0 and p.favoritecount>=0 and u.reputation>=1 and u.reputation<=113 and u.views>=0 and u.views<=51;"
        # cls.sql = "select count(*) from badges as b, comments as c, users as u, votes as v where b.userid = c.userid and c.userid = u.id and u.id = v.userid and b.date >= 1279574948 and c.score = 0 and u.creationdate <= 1410173533 and u.creationdate >= 1279581345 and u.reputation <= 305 and u.views <= 77 and v.bountyamount >= 0 and v.votetypeid = 2;"
        # cls.sql = "SELECT COUNT(*) FROM badges as b, posts as p WHERE b.UserId = p.OwnerUserId AND b.Date<='2014-09-11 08:55:52'::timestamp AND p.AnswerCount>=0 AND p.AnswerCount<=4 AND p.CommentCount>=0 AND p.CommentCount<=17;"
        
        # cls.sql = "SELECT COUNT(*) FROM comments as c, posts as p, postLinks as pl WHERE c.UserId = p.OwnerUserId AND p.Id = pl.PostId AND c.Score=0 AND p.CreationDate>='2010-09-06 00:58:21'::timestamp AND p.CreationDate<='2014-09-12 10:02:21'::timestamp AND pl.LinkTypeId=1 AND pl.CreationDate>='2011-07-09 22:35:44'::timestamp;"
        cls.data_interactor.pull_subquery_card()
        cls.data_interactor.pull_estimated_cost()
        cls.data_interactor.pull_physical_plan()
        cls.origin_result = cls.data_interactor.execute(cls.sql)
       # print(cls.origin_result)
    
    def test_p_error(self):
        p_error_pg = p_error_calc(self.config, self.sql, self.origin_result.subquery_2_card)
        print("P-error of pg's cardinality estimator is",p_error_pg)
        
        true_cards = {}
        for k in self.origin_result.subquery_2_card.keys():
            self.data_interactor.pull_record()
            res = self.data_interactor.execute(k)
            true_cards[k] = int(res.records.values[0][0])
        print(true_cards)

        p_error_true_card = p_error_calc(self.config, self.sql, true_cards)
        print("P-error of true card is", p_error_true_card)

        p_error_true_card = p_error_calc(self.config, self.sql, self.origin_result.subquery_2_card, true_cards)
        # With pre-calcuated true card, the function runs faster.
        print("P-error of pg's cardinality estimator is", p_error_true_card)

        

if __name__ == '__main__':
    unittest.main()