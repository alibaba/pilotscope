from concurrent.futures.thread import ThreadPoolExecutor

from pilotscope.Anchor.BaseAnchor.PushAnchorHandler import HintAnchorHandler
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum, ExperimentTimeEnum
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.Util import wait_futures_results


def modify_sql_for_spark(config, sql: str):
    if config.db_type == DatabaseEnum.SPARK:
        sql = sql.replace("::timestamp", "")
    return sql


class BaoParadigmHintAnchorHandler(HintAnchorHandler):
    class HintForBao:
        def __init__(self, db_type: DatabaseEnum) -> None:  # Hint Chores Factory
            if db_type == DatabaseEnum.POSTGRESQL:
                self.ALL_OPTIONS = [
                    "enable_nestloop", "enable_hashjoin", "enable_mergejoin",
                    "enable_seqscan", "enable_indexscan", "enable_indexonlyscan"
                ]
                self.ARMS_OPTION = [63, 62, 43, 42, 59]  # each arm's option in binary format
                self.arms_hint2val = [self.arm_idx_to_hint2val(i, self.ARMS_OPTION, self.ALL_OPTIONS, ["off", "on"]) for
                                      i in range(len(self.ARMS_OPTION))]
                pass
            elif db_type == DatabaseEnum.SPARK:
                self.ALL_OPTIONS = [
                    "spark.sql.cbo.enabled",
                    "spark.sql.join.preferSortMergeJoin",
                    "spark.sql.adaptive.skewJoin.enabled",
                    "spark.sql.codegen.wholeStag",
                    "spark.sql.cbo.joinReorder.enabled  ",
                    "spark.sql.sources.bucketing.autoBucketedScan.enabled"
                ]
                self.ARMS_OPTION = [63, 62, 43, 42, 59]  # each arm's option in binary format
                self.arms_hint2val = [self.arm_idx_to_hint2val(i, self.ARMS_OPTION, self.ALL_OPTIONS, ["false", "true"])
                                      for i in range(len(self.ARMS_OPTION))]
            else:
                raise NotImplementedError

        def arm_idx_to_hint2val(self, arm_idx, arms_option, all_options, value_names: list):
            hint2val = dict()
            for i in range(len(all_options)):
                hint2val[all_options[i]] = value_names[1 & (arms_option[arm_idx] >> i)]
            return hint2val

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.bao_hint = self.HintForBao(config.db_type)

    def predict(self, plans):
        return self.model.user_model.predict(plans)

    def user_custom_task(self, sql):
        sql = modify_sql_for_spark(self.config, sql)
        try:
            TimeStatistic.start(ExperimentTimeEnum.AI_TASK)
            # with ThreadPoolExecutor(max_workers=len(self.bao_hint.arms_hint2val)) as pool:
            with ThreadPoolExecutor(max_workers=1) as pool:
                futures = []
                for hint2val in self.bao_hint.arms_hint2val:
                    future = pool.submit(self._get_plan, sql, hint2val)
                    futures.append(future)
                plans = wait_futures_results(futures)
                pass

            origin_plans = plans
            plans = []
            if self.config.db_type == DatabaseEnum.SPARK:
                for plan in origin_plans:
                    plan = to_tree_json(plan)
                    compress = SparkPlanCompress()
                    plan["Plan"] = compress.compress(plan["Plan"])
                    plans.append(plan)

            TimeStatistic.start(ExperimentTimeEnum.PREDICT)
            est_exe_time = self.model.user_model.predict(plans)
            TimeStatistic.end(ExperimentTimeEnum.PREDICT)
            print("BAO: ", est_exe_time, flush = True)
            TimeStatistic.end(ExperimentTimeEnum.AI_TASK)
            idx = est_exe_time.argmin()
            pass
        except Exception as e:
            idx = 0
        return self.bao_hint.arms_hint2val[idx]

    def _get_plan(self, sql, hint2val):
        pilot_state_manager = PilotDataInteractor(self.config)
        # print(hint2val)
        pilot_state_manager.push_hint(hint2val)
        pilot_state_manager.pull_physical_plan()
        if self.model.have_cache_data:
            pilot_state_manager.pull_buffercache()

        data: PilotTransData = pilot_state_manager.execute(sql)
        plan = data.physical_plan
        if self.model.have_cache_data:
            plan["Buffers"] = data.buffercache
        return plan
