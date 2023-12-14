import unittest
import random

from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData
from pilotscope.Exception.Exception import PilotScopeInternalError

class MyTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(self):
        self.config = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.data_interactor = PilotDataInteractor(self.config)
        self.sql = "select count(*) from  badges as b, comments as c, users as u, votes as v where b.userid = c.userid and c.userid = u.id and u.id = v.userid and b.date >= 1279574948 and c.score = 0 and u.creationdate <= 1410173533 and u.creationdate >= 1279581345 and u.reputation <= 305 and u.views <= 77 and v.bountyamount >= 0 and v.votetypeid = 2;"
        self.data_interactor.pull_subquery_card(enable_parameterized_subquery=False)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        self.origin_result = self.data_interactor.execute(self.sql)
    
    def _test_push_card_to_cost(self, factor, enable_parameterized_subquery):
        new_cards = {k:max(1,int(v*factor)) for k,v in self.origin_result.subquery_2_card.items()}
        self.data_interactor.push_card(new_cards, enable_parameterized_subquery)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        result = self.data_interactor.execute(self.sql)
        flag = False
        for _,v in new_cards.items():
            flag = (str(v) in str(result.physical_plan)) or flag
        self.assertTrue(flag) # check if some new values have injected to plan
        print("factor: ", factor, " cost is ",result.estimated_cost)
        return result.estimated_cost
        
    def test_push_card_to_cost(self):
        print("\n")
        print("factor: ", 1, " cost is ",self.origin_result.estimated_cost)
        factor = 1
        costs = [self.origin_result.estimated_cost]
        for i in range(10):
            factor *= 10
            cost = self._test_push_card_to_cost(factor, False)
            costs.append(cost)
        self.assertTrue(all(costs[i] <= costs[i+1] for i in range(len(costs)-1))) # check costs is non-decreasing.
        
        print("\n")
        print("factor: ", 1, " cost is ",self.origin_result.estimated_cost)
        factor = 1
        costs = [self.origin_result.estimated_cost]
        for i in range(10):
            factor *= 10
            cost = self._test_push_card_to_cost(1/factor, False)
            costs.append(cost)
        # self.assertTrue(all(costs[i] >= costs[i+1] for i in range(len(costs)-1))) # check costs is non-increasing.
            
    def test_enable_parameterized_subquery_consistency(self):
        self.data_interactor.push_card(self.origin_result.subquery_2_card, True)
        self.data_interactor.pull_physical_plan()
        # self.data_interactor.execute(self.sql)
        try:
            self.data_interactor.execute(self.sql)
            self.assertTrue(False, "enable_parameterized_subquery is inconsistency in pull_subquery and push_card, it should be an error.")
        except Exception as e:
            self.assertEqual(type(e), PilotScopeInternalError)
            self.assertTrue("Can not find the corresponding sub-plan query in push anchor", str(e))
    
    def test_card_consistency(self):
        model_subquery_2_card = {}
        for i, subquery in enumerate(self.origin_result.subquery_2_card):
            model_subquery_2_card[subquery] = random.randint(1, 10000000)
        self.data_interactor.push_card(model_subquery_2_card)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        result = self.data_interactor.execute(self.sql)
        flag = False
        for _,v in model_subquery_2_card.items():
            flag = (str(v) in str(result.physical_plan)) or flag
        self.assertTrue(flag) # check if some new values have injected to plan
        
        

if __name__ == '__main__':
    unittest.main()