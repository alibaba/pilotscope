import unittest
import random

from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.Common.Index import Index
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Exception.Exception import PilotScopeMutualExclusionException
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotTransData import PilotTransData


class TestDataInteractor(unittest.TestCase):

    def __init__(self, methodName="runTest", skip_init=False):
        super().__init__(methodName)
        if not skip_init:
            self.config = PostgreSQLConfig()
            self.config.db = "stats_tiny"
            self.config.enable_deep_control_local(example_pg_bin, example_pgdata)
            self.data_interactor = PilotDataInteractor(self.config)
            self.db_controller = DBControllerFactory.get_db_controller(self.config)

        self.sql = "select count(*) from posts as p, postlinks as pl, posthistory as ph where p.id = pl.postid and pl.postid = ph.postid and p.creationdate>=1279570117 and ph.creationdate>=1279585800 and p.score < 50;"

        self.table = "badges"
        self.index_column = "date"

    def test_pull_execution_time(self):
        print("\nTest Pull Execution Time")
        self.data_interactor.pull_execution_time()
        result = self.data_interactor.execute(self.sql)
        self.assertFalse(result.execution_time is None)

    def test_pull_physical_plan(self):
        print("\nTest Pull Physical Plan")
        self.data_interactor.pull_physical_plan()
        result: PilotTransData = self.data_interactor.execute(self.sql)
        self.assertFalse(result.physical_plan is None)

    def test_pull_subquery_card(self):
        print("\nTest Pull Subquery")
        self.data_interactor.pull_subquery_card()
        result: PilotTransData = self.data_interactor.execute(self.sql)
        self.assertFalse(result.subquery_2_card is None or len(result.subquery_2_card) == 0)
        print(result)

    def test_pull_estimated_cost(self):
        print("\nTest Pull Estimated Cost")
        self.data_interactor.pull_estimated_cost()
        result: PilotTransData = self.data_interactor.execute(self.sql)
        self.assertFalse(result.estimated_cost is None)
        print(result)

    def test_pull_buffer_cache(self):
        print("\nTest Pull Buffer Cache")
        self.data_interactor.pull_buffercache()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.buffercache)
        self.assertTrue(data.buffercache is not None)

    def test_pull_record(self):
        print("\nTest Pull Record")
        self.data_interactor.pull_record()
        data: PilotTransData = self.data_interactor.execute(self.sql)  # pull_physical_plan should execute first
        print(data.records)
        self.assertTrue(data.records is not None)

    def test_push_knob(self):
        print("\nTest Push Knob")
        self.data_interactor.push_knob({"max_connections": "101"})
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show max_connections;")
        self.db_controller.recover_config()
        print(data.records)
        self.assertEqual(data.records.values[0][0], '101')  # even reset, knob don't change

    def test_push_hint(self):
        print("\nTest Push Hint")
        self.data_interactor.push_hint({"enable_nestloop": "off"})
        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;", is_reset=True)
        self.assertEqual(data.records.values[0][0], "off")

        self.data_interactor.pull_record()
        data = self.data_interactor.execute("show enable_nestloop;")
        # data = self.data_interactor.execute("select pg_backend_pid();")
        print(data.records)
        self.assertEqual(data.records.values[0][0], "on")

    def test_push_index(self):
        print("\nTest Push Index")
        table = self.table
        index = Index(columns=[self.index_column], table=table, index_name="{}_{}".format(table, self.index_column))
        self.db_controller.drop_index(index)

        origin_index_size = self.db_controller.get_index_number(table)
        self.data_interactor.push_index([index], False)
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.execute(self.sql, is_reset=False)
        self.assertTrue(self.db_controller.get_index_number(table) == origin_index_size + 1)
        self.db_controller.drop_index(index)
        self.assertTrue(self.db_controller.get_index_number(table) == origin_index_size)

    def test_push_simulated_index(self):
        print("\nTest Push Simulated Index")
        table = self.table
        index = Index(columns=[self.index_column], table=table, index_name="{}_{}".format(table, self.index_column))

        data_interactor = PilotDataInteractor(self.config, enable_simulate_index=True)
        data_interactor.push_index([index], False)
        data_interactor.pull_estimated_cost()
        data_interactor.execute(self.sql, is_reset=False)

        simulated_index_size = data_interactor.db_controller.get_index_number(table)
        self.assertTrue(simulated_index_size == 1)

        # the simulated index will be deleted after terminating connection
        data_interactor.reset()
        simulated_index_size = data_interactor.db_controller.get_index_number(table)
        self.assertTrue(simulated_index_size == 0)

    def test_push_index_by_cost(self):
        print("\nTest Push Index by Cost")
        sql = "select date from badges where date=1406838696"
        index_name = "{}_{}".format(self.table, self.index_column)
        index_before = self.data_interactor.db_controller.get_all_indexes()

        # insert a new index and record the cost of SQL query
        index = Index([self.index_column], self.table, index_name=index_name)
        self.data_interactor.push_index([index], drop_other=True)
        self.data_interactor.pull_estimated_cost()
        res = self.data_interactor.execute(sql)
        index_cost = res.estimated_cost

        # Reset indexes
        self.data_interactor.push_index(index_before, drop_other=True)
        self.data_interactor.pull_estimated_cost()
        res = self.data_interactor.execute(sql)
        origin_cost = res.estimated_cost
        print("index_cost is {}, origin_cost is {}".format(index_cost, origin_cost))
        self.assertTrue(origin_cost - index_cost > 0)

    def test_push_pg_hint_comment(self):
        print("\nTest Push PG Hint Comment")
        self.data_interactor.pull_subquery_card()
        self.data_interactor.pull_estimated_cost()
        self.data_interactor.pull_physical_plan()
        self.origin_result = self.data_interactor.execute(self.sql)

        larger_card = {k: v * 10000 for k, v in self.origin_result.subquery_2_card.items()}
        self.data_interactor.push_card(larger_card)
        self.data_interactor.pull_physical_plan()
        self.data_interactor.pull_estimated_cost()
        result = self.data_interactor.execute(self.sql)
        print("cost is ", result.estimated_cost, ". before push_card, cost is", self.origin_result.estimated_cost)
        self.assertTrue(result.estimated_cost > self.origin_result.estimated_cost * 10)
        print(result.physical_plan)

        self.data_interactor.push_card(larger_card)
        self.data_interactor.push_pg_hint_comment("/*+SeqScan(b) SeqScan(u) SeqScan(c) SeqScan(v)*/")
        self.data_interactor.pull_physical_plan()
        self.data_interactor.pull_estimated_cost()
        result = self.data_interactor.execute(self.sql)
        print("after set pg_hint_plan, cost is ", result.estimated_cost)
        self.assertTrue("Index Scan" not in str(result.physical_plan))
        print(result.physical_plan)

    def test_push_pull_any_combination(self):
        print("\nTest Push any Combination")
        # all_operators = [x for x in dir(self.data_interactor) if (x.startswith("push_") or x.startswith("pull_"))]
        all_operators = ['pull_buffercache', 'pull_estimated_cost', 'pull_execution_time', 'pull_physical_plan',
                         'pull_record', 'pull_subquery_card', 'push_card', 'push_hint', 'push_index', 'push_knob']
        data_for_push = {
            "push_index": self.data_interactor.db_controller.get_all_indexes(),
            "push_hint": {"enable_nestloop": "off"},
            "push_knob": {"max_connections": "101"}
        }
        self.data_interactor.pull_subquery_card()
        result = self.data_interactor.execute(self.sql)
        data_for_push["push_card"] = result.subquery_2_card
        max_val = 1 << len(all_operators)
        print(max_val)
        random.seed(0)
        for v in random.sample(range(1, max_val), 50):  # enlarge this to test more
            applied_op = set()
            for i in range(len(all_operators)):
                if ((v >> i) & 1) == 1:
                    op_name = all_operators[i]
                    applied_op.add(op_name)
                    if op_name.startswith("push_"):
                        getattr(self.data_interactor, op_name)(data_for_push[op_name])
                    else:
                        getattr(self.data_interactor, op_name)()
            try:
                data = self.data_interactor.execute(self.sql)
                print(applied_op)
            except PilotScopeMutualExclusionException as e:
                continue
            if "pull_buffercache" in applied_op:
                self.assertTrue(data.buffercache is not None)
            if "pull_estimated_cost" in applied_op:
                self.assertTrue(data.estimated_cost > 0)
            if "pull_execution_time" in applied_op:
                self.assertTrue(data.execution_time > 0)
            if "pull_physical_plan" in applied_op:
                self.assertTrue(data.physical_plan is not None)
            if "pull_record" in applied_op:
                self.assertTrue(data.records is not None)
        print(all_operators)
        self.data_interactor.push_knob({"max_connections": "100"})
        try:
            self.data_interactor.execute("select 1")
        except PilotScopeMutualExclusionException as e:
            pass
        self.db_controller.recover_config()

    def test_anchor_mutual_exclusion(self):
        print("\nTest Anchor Mutual Exclusion")
        try:
            self.data_interactor.pull_subquery_card()
            self.data_interactor.push_card({})
            self.data_interactor.execute(self.sql)
        except PilotScopeMutualExclusionException as e:
            self.assertTrue(True)
        except Exception as e:
            self.assertTrue(False)


if __name__ == '__main__':
    unittest.main()
