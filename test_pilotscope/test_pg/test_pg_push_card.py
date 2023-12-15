import unittest
import random

from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData


class MyTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.data_interactor = PilotDataInteractor(cls.config)
        cls.sql = "select count(*) from badges as b, comments as c, users as u, votes as v where b.userid = c.userid and c.userid = u.id and u.id = v.userid and b.date >= 1279574948 and c.score = 0 and u.creationdate <= 1410173533 and u.creationdate >= 1279581345 and u.reputation <= 305 and u.views <= 77 and v.bountyamount >= 0 and v.votetypeid = 2;"
        cls.data_interactor.pull_subquery_card()
        cls.data_interactor.pull_estimated_cost()
        cls.data_interactor.pull_physical_plan()
        cls.origin_result = cls.data_interactor.execute(cls.sql)

    def test_push_card_to_cost(self):
        larger_card = {k: v * 10000 for k, v in self.origin_result.subquery_2_card.items()}
        self.data_interactor.push_card(larger_card)
        self.data_interactor.pull_estimated_cost()
        result = self.data_interactor.execute(self.sql)
        print("cost is ", result.estimated_cost, ". before push_card, cost is", self.origin_result.estimated_cost)
        self.assertTrue(result.estimated_cost > self.origin_result.estimated_cost * 100)

        smaller_card = {k: max(1, v / 100) for k, v in self.origin_result.subquery_2_card.items()}
        self.data_interactor.push_card(smaller_card)
        self.data_interactor.pull_estimated_cost()
        result = self.data_interactor.execute(self.sql)
        print("cost is ", result.estimated_cost, ". before push_card, cost is", self.origin_result.estimated_cost)
        self.assertTrue(result.estimated_cost < self.origin_result.estimated_cost * 2)

    def test_card_consistency(self):
        model_subquery_2_card = {}
        for i, subquery in enumerate(self.origin_result.subquery_2_card):
            model_subquery_2_card[subquery] = random.randint(1, 10000000)
        self.data_interactor.push_card(model_subquery_2_card)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        result = self.data_interactor.execute(self.sql)
        flag = False
        for _, v in model_subquery_2_card.items():
            flag = (str(v) in str(result.physical_plan)) or flag
        self.assertTrue(flag)  # check if some new values have injected to plan


if __name__ == '__main__':
    unittest.main()
