import sys

from pandas import DataFrame

sys.path.append("../algorithm_examples/Bao/source")
sys.path.append("../")

from pilotscope.DataManager.DataManager import DataManager
from pilotscope.Common.dotDrawer import PlanDotDrawer

import unittest
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Bao.BaoParadigmHintAnchorHandler import BaoHintPushHandler
from algorithm_examples.Bao.BaoPilotModel import BaoPilotModel
from algorithm_examples.Bao.EventImplement import BaoPretrainingModelEvent
from algorithm_examples.utils import load_test_sql


class BaoTest(unittest.TestCase):
    def setUp(self):
        self.config: PostgreSQLConfig = PostgreSQLConfig(db_host="localhost", db_port="5432", db_user="postgres",
                                                         db_user_pwd="postgres")
        self.config.db = "stats_tiny"

        self.used_cache = False
        if self.used_cache:
            self.model_name = "bao_model_wc"
        else:
            self.model_name = "bao_model"

        self.test_data_table = "{}_{}_test_data_table".format(self.model_name, self.config.db)
        self.pg_test_data_table = "{}_{}_test_data_table".format("pg", self.config.db)
        self.pretraining_data_table = ("bao_{}_pretraining_collect_data".format(self.config.db)
                                       if not self.used_cache
                                       else "bao_{}_pretraining_collect_data_wc".format(self.config.db))
        self.algo = "bao"

    def test_bao(self):
        try:
            config = self.config
            config.once_request_timeout = config.sql_execution_timeout = 500
            config.print()

            bao_pilot_model: BaoPilotModel = BaoPilotModel(self.model_name, have_cache_data=self.used_cache)
            bao_pilot_model.load_model()
            bao_handler = BaoHintPushHandler(bao_pilot_model, config)

            # core
            scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
            scheduler.register_custom_handlers([bao_handler])
            scheduler.register_required_data(self.test_data_table, pull_physical_plan=True, pull_execution_time=True,
                                             pull_buffer_cache=self.used_cache)

            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, self.pretraining_data_table,
                                                         enable_collection=False,
                                                         enable_training=False)
            scheduler.register_events([pretraining_event])

            # start
            scheduler.init()
            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, total is {}".format(i, len(sqls)))
                scheduler.execute(sql)
            print("run ok")
        finally:
            pilotscope_exit()

    def test_draw_plan(self):
        train_data_manager = DataManager(self.config)
        df = train_data_manager.read_all(self.pretraining_data_table)
        res = PlanDotDrawer.get_plan_dot_str(df["plan"][2])
        pass

    def test_compare_for_experiment(self):
        train_data_manager = DataManager(self.config)
        df_bao = train_data_manager.read_all(self.test_data_table)
        df_pg = train_data_manager.read_all(self.pg_test_data_table)
        df = DataFrame(data={
            "pg": list(df_bao["execution_time"]),
            "bao": list(df_pg["execution_time"])
        })

        df.to_excel("./Experiment/Data/{}_plan_compare.xlsx".format(self.config.db))



if __name__ == '__main__':
    unittest.main()
