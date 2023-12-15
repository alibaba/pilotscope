import unittest
import random

from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.Exception.Exception import PilotScopeMutualExclusionException
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum


# Some IDE run test parallel by default. To avoid that another test's sql execution runs while restarting database
# accidentally, DO NOT put test_anchor_combination together with other test functions in the same class.

class MyTestCase(unittest.TestCase):

    def __init__(self, methodName="runTest"):
        super().__init__(methodName)
        self.config = PostgreSQLConfig()
        self.config.db = "stats_tiny"
        self.config.enable_deep_control_local(example_pg_bin, example_pgdata)
        self.data_interactor = PilotDataInteractor(self.config)
        self.sql = "select count(*) from posts as p, postlinks as pl, posthistory as ph where p.id = pl.postid and pl.postid = ph.postid and p.creationdate>=1279570117 and ph.creationdate>=1279585800 and p.score < 50;"

    def test_anchor_combination(self):
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

if __name__ == "__main__":
    unittest.main()
