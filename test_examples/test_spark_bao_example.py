import sys
sys.path.append("../examples/Bao/source")
sys.path.append("../")
from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from SparkPlanCompress import SparkPlanCompress
from pilotscope.common.Drawer import Drawer
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.dotDrawer import PlanDotDrawer
from examples.ExampleConfig import get_time_statistic_img_path, get_time_statistic_xlsx_file_path
from examples.Bao.source.model import BaoRegression

import unittest
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig, SparkConfig
from pilotscope.PilotEnum import *
from pilotscope.PilotScheduler import PilotScheduler
from examples.Bao.BaoParadigmHintAnchorHandler import BaoParadigmHintAnchorHandler, modify_sql_for_spark
from examples.Bao.BaoPilotModel import BaoPilotModel
from examples.Bao.EventImplement import BaoPretrainingModelEvent
from examples.utils import load_test_sql, to_tree_json


class SparkBaoTest(unittest.TestCase):
    def setUp(self):
        db = "stats_tiny"
        self.config: SparkConfig = SparkConfig(app_name="PiloScopeBao", master_url="local[*]")
        self.config.use_postgresql_datasource(SparkSQLDataSourceEnum.POSTGRESQL, host="localhost", db=db,
                                              user="postgres", pwd="postgres")
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.executor.memory": "40g",
            "spark.driver.memory": "40g"
        })

        self.used_cache = False
        if self.used_cache:
            self.model_name = "spark_bao_model_wc"
        else:
            self.model_name = "spark_bao_model"

        self.test_data_table = "{}_{}_test_data_table5".format(self.model_name, self.config.db)
        self.db_test_data_table = "{}_{}_test_data_table5".format("spark", self.config.db)
        self.pretraining_data_table = ("spark_bao_{}_pretraining_collect_data6".format(self.config.db)
                                       if not self.used_cache
                                       else "spark_bao_{}_pretraining_collect_data_wc".format(self.config.db))
        self.algo = "spark_bao"

    def test_0_bao(self):
        try:
            config = self.config
            config.once_request_timeout = config.sql_execution_timeout = 50000
            config.print()

            bao_pilot_model: BaoPilotModel = BaoPilotModel(self.model_name, have_cache_data=self.used_cache,
                                                           is_spark=True)
            bao_pilot_model.load()
            bao_handler = BaoParadigmHintAnchorHandler(bao_pilot_model, config)

            # Register what data needs to be cached for training purposes
            data_interactor = PilotDataInteractor(config)
            data_interactor.pull_physical_plan()
            data_interactor.pull_execution_time()
            if self.used_cache:
                data_interactor.pull_buffercache()

            # core
            scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
            scheduler.register_anchor_handler(bao_handler)
            scheduler.register_collect_data(training_data_save_table=self.test_data_table,
                                            data_interactor=data_interactor)

            pretraining_event = BaoPretrainingModelEvent(config, bao_pilot_model, self.pretraining_data_table,
                                                         enable_collection=True,
                                                         enable_training=True)
            scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)
            # start
            scheduler.init()

            print("start to test sql")
            sqls = load_test_sql(config.db)
            for i, sql in enumerate(sqls):
                sql = modify_sql_for_spark(config, sql)
                print("current is the {}-th sql, total is {}".format(i, len(sqls)))
                TimeStatistic.start(ExperimentTimeEnum.SQL_END_TO_END)
                scheduler.simulate_db_console(sql)
                TimeStatistic.end(ExperimentTimeEnum.SQL_END_TO_END)
                TimeStatistic.save_xlsx(get_time_statistic_xlsx_file_path(self.algo, config.db))
            name_2_value = TimeStatistic.get_average_data()
            Drawer.draw_bar(name_2_value, get_time_statistic_img_path(self.algo, self.config.db), is_rotation=True)
            print("run ok")
        finally:
            pilotscope_exit()

if __name__ == '__main__':
    unittest.main()
