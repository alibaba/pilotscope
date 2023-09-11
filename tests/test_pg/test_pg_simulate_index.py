import unittest

from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.common.Index import Index

class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        
    @classmethod
    def setUpClass(cls):
        cls.config = PostgreSQLConfig()
        cls.config.db = "stats_tiny"
        cls.config.set_db_type(DatabaseEnum.POSTGRESQL)
        cls.db_controller: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config)
        cls.db_controller_hypo_index: PostgreSQLController = DBControllerFactory.get_db_controller(cls.config,enable_simulate_index = True)
        cls.sql = "select date from badges where date=1406838696"
        cls.table = "badges"
        cls.column = "date"
    
    def test_get_oid(self):
        index = Index([self.column], self.table, index_name="test_index")
        self.db_controller_hypo_index.create_index(index)
        print(index.hypopg_oid, index.hypopg_name)
        res = self.db_controller_hypo_index.simulate_index_visitor._get_oid_by_indexname(index_name=index.hypopg_name)
        self.assertTrue(res == index.hypopg_oid)
        res = self.db_controller_hypo_index.simulate_index_visitor._get_oid_by_indexname(index_name=self.table+"_"+self.column)
        self.assertTrue(res == index.hypopg_oid)
        self.db_controller_hypo_index.drop_all_indexes()
        
    def test_create_hypothetical_index(self):
        index = Index([self.column], self.table, index_name="test_index")
        
        no_index_plan = self.db_controller.explain_physical_plan(self.sql)
        no_index_cost = no_index_plan["Plan"]["Total Cost"]
        print(no_index_plan)
        
        self.db_controller.create_index(index)
        real_index_plan = self.db_controller.explain_physical_plan(self.sql)
        real_index_cost = real_index_plan["Plan"]["Total Cost"]
        real_index_size = self.db_controller.get_index_byte(index)
        self.db_controller.drop_index(index)
        print(real_index_plan)
        
        self.db_controller_hypo_index.create_index(index)
        hypo_no_index_plan = self.db_controller_hypo_index.explain_physical_plan(self.sql)
        hypo_index_cost = real_index_plan["Plan"]["Total Cost"]
        hypo_index_size = self.db_controller_hypo_index.get_index_byte(index)
        print(hypo_no_index_plan)
        self.db_controller_hypo_index.drop_index(index)
        
        print(real_index_size, hypo_index_size)
        self.assertTrue(max(real_index_size/hypo_index_size, hypo_index_size/real_index_size)<10) 
        self.assertTrue(abs(hypo_index_cost-real_index_cost)<2) # estimated cost of real index approximately equals estimated cost of hypothetical index
        self.assertTrue(hypo_index_cost<no_index_cost)
        
        self.db_controller_hypo_index.drop_all_indexes()
        
    def test_all_indexes_stuff(self):
        bytes_origin = self.db_controller_hypo_index.get_all_indexes_byte()
        self.assertTrue(bytes_origin == 0)
        bytes_origin_table = self.db_controller_hypo_index.get_table_indexes_byte(self.table)
        all_index = self.db_controller_hypo_index.get_all_indexes()
        number_origin = self.db_controller_hypo_index.get_index_number(self.table)
        
        index = Index([self.column], self.table, index_name="test_index")
        self.db_controller_hypo_index.create_index(index)
        hypo_index_size = self.db_controller_hypo_index.get_index_byte(index)
        bytes_after = self.db_controller_hypo_index.get_all_indexes_byte()
        bytes_after_table = self.db_controller_hypo_index.get_table_indexes_byte(self.table)
        all_index_after = self.db_controller_hypo_index.get_all_indexes()
        number_after = self.db_controller_hypo_index.get_index_number(self.table)
        print(bytes_origin,hypo_index_size,bytes_after)
        self.assertTrue(bytes_origin+hypo_index_size == bytes_after) # byte size for all indexes
        self.assertTrue(bytes_origin_table+hypo_index_size == bytes_after_table) # byte size per table
        print(all_index, all_index_after)
        self.assertTrue(len(all_index) + 1 == len(all_index_after))
        print(number_origin, number_after)
        self.assertTrue(number_origin == 0 and number_after == 1)
        
        self.db_controller_hypo_index.drop_all_indexes()
        
    def test_get_existed_index(self):
        res = self.db_controller_hypo_index.get_existed_index(self.table)
        index = Index([self.column], self.table, index_name="test_index")
        self.db_controller_hypo_index.create_index(index)
        res_after = self.db_controller_hypo_index.get_existed_index(self.table)
        print(res,res_after)
        self.assertTrue("[badges: date]" == str(res_after))
        
        self.db_controller_hypo_index.drop_all_indexes()

    @classmethod
    def tearDownClass(cls):
        pass


if __name__ == '__main__':
    unittest.main()
