from concurrent.futures.thread import ThreadPoolExecutor

from Anchor.BaseAnchor.replaceAnchorHandler import HintAnchorHandler
from DataFetcher.PilotStateManager import PilotStateManager
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum, ExperimentTimeEnum
from PilotModel import PilotModel
from PilotTransData import PilotTransData
from common.TimeStatistic import TimeStatistic
from common.Util import wait_futures_results


class BaoParadigmHintAnchorHandler(HintAnchorHandler):
    class HintForBao:
        def __init__(self, db_type: DatabaseEnum) -> None:  # Hint Chores Factory
            if db_type == DatabaseEnum.POSTGRESQL:
                self.ALL_OPTIONS = [
                    "enable_nestloop", "enable_hashjoin", "enable_mergejoin",
                    "enable_seqscan", "enable_indexscan", "enable_indexonlyscan"
                ]
                self.ARMS_OPTION = [63, 62, 43, 42, 59]  # each arm's option in binary format

                def arm_idx_to_hint2val(arm_idx):
                    hint2val = dict()
                    for i in range(len(self.ALL_OPTIONS)):
                        hint2val[self.ALL_OPTIONS[i]] = ["off", "on"][1 & (self.ARMS_OPTION[arm_idx] >> i)]
                    return hint2val

                self.arms_hint2val = [arm_idx_to_hint2val(i) for i in range(len(self.ARMS_OPTION))]
            elif db_type == DatabaseEnum.SPARK:
                raise NotImplementedError
            else:
                raise KeyError

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.bao_hint = self.HintForBao(config.db_type)

    def predict(self, plans):
        return self.model.user_model.predict(plans)

    def user_custom_task(self, sql):
        try:
            TimeStatistic.start(ExperimentTimeEnum.AI_TASK)
            with ThreadPoolExecutor(max_workers=len(self.bao_hint.arms_hint2val)) as pool:
                futures = []
                for hint2val in self.bao_hint.arms_hint2val:
                    future = pool.submit(self._get_plan, sql, hint2val)
                    futures.append(future)
                plans = wait_futures_results(futures)
                pass

            TimeStatistic.start(ExperimentTimeEnum.PREDICT)
            est_exe_time = self.model.user_model.predict(plans)
            TimeStatistic.end(ExperimentTimeEnum.PREDICT)
            print("BAO: ", est_exe_time)
            TimeStatistic.end(ExperimentTimeEnum.AI_TASK)
            idx = est_exe_time.argmin()
            pass
        except Exception as e:
            raise e
            print(e)
            idx = 0
        return self.bao_hint.arms_hint2val[idx]

    def _get_plan(self, sql, hint2val):
        pilot_state_manager = PilotStateManager(self.config)
        # print(hint2val)
        pilot_state_manager.set_hint(hint2val)
        pilot_state_manager.fetch_physical_plan()
        if self.model.have_cache_data:
            pilot_state_manager.fetch_buffercache()

        data: PilotTransData = pilot_state_manager.execute(sql)
        plan = data.physical_plan
        if self.model.have_cache_data:
            plan["Buffers"] = data.buffercache
        return plan


