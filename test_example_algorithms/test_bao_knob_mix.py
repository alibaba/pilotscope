import sys

sys.path.append("../")
sys.path.append("../algorithm_examples/Bao/source")

import unittest
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.Common.Util import pilotscope_exit
from pilotscope.PilotConfig import PostgreSQLConfig
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Bao.BaoParadigmHintAnchorHandler import BaoHintPushHandler
from algorithm_examples.Bao.BaoPilotModel import BaoPilotModel
from algorithm_examples.Bao.EventImplement import BaoPretrainingModelEvent
from algorithm_examples.KnobTuning.EventImplement import KnobPeriodicModelUpdateEvent
from algorithm_examples.utils import load_test_sql


class BaoTest(unittest.TestCase):
    def setUp(self):
        self.config: PostgreSQLConfig = PostgreSQLConfig()
        # self.config.db = "imdbfull"
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
        self.algo = "bao_knob"

    def test_bao_knob(self):
        try:
            config = self.config
            config.once_request_timeout = config.sql_execution_timeout = 20000
            config.print()

            bao_pilot_model: BaoPilotModel = BaoPilotModel(self.model_name, have_cache_data=self.used_cache)
            bao_pilot_model.load_model()
            bao_handler = BaoHintPushHandler(bao_pilot_model, config)

            # core
            scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
            scheduler.register_custom_handlers([bao_handler])
            scheduler.register_required_data(table_name_for_store_data=self.test_data_table, pull_execution_time=True,
                                             pull_physical_plan=True, pull_buffer_cache=self.used_cache)

            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, self.pretraining_data_table,
                                                         enable_collection=True,
                                                         enable_training=True)
            periodic_db_controller_event = KnobPeriodicModelUpdateEvent(config, 200,
                                                                        llamatune_config_file="../algorithm_examples/KnobTuning/llamatune/configs/llama_config.ini",
                                                                        execute_on_init=True, optimizer_type="smac")
            scheduler.register_events([pretraining_event, periodic_db_controller_event])
            # start
            scheduler.init()
            print("start to test sql")
            sqls = load_test_sql(config.db)
            print(sqls)
            for i, sql in enumerate(sqls):
                print("current is the {}-th sql, total is {}".format(i, len(sqls)))
                scheduler.execute(sql)
            print("run ok !!")
        finally:
            pilotscope_exit()


if __name__ == '__main__':
    unittest.main()
