from typing import List

from pilotscope.Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from pilotscope.Anchor.BaseAnchor.BasePullHandler import RecordPullHandler, BasePullHandler
from pilotscope.Anchor.BaseAnchor.BasePushHandler import BasePushHandler
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotEnum import *
from pilotscope.PilotEvent import *
from pilotscope.PilotTransData import PilotTransData
from pilotscope.Common.TimeStatistic import TimeStatistic
from pilotscope.Common.Util import extract_handlers


class PilotScheduler:

    def __init__(self, config: PilotConfig) -> None:
        self.config = config
        self.table_name_for_store_data = None
        self.data_manager: DataManager = DataManager(self.config)
        self.db_controller = DBControllerFactory.get_db_controller(self.config)
        self.events = []
        self.user_tasks: List[BasePushHandler] = []
        self.data_interactor = PilotDataInteractor(self.config)

    def init(self):
        self._deal_initial_events()

    def execute(self, sql):
        data_interactor = self.data_interactor

        # add recordPullAnchor
        record_handler = RecordPullHandler(self.config)
        data_interactor.add_anchor(record_handler.anchor_name, record_handler)

        # add all replace anchors from user
        data_interactor.add_anchors(self.user_tasks)

        # replace value based on user's method

        for replace_handle in self.user_tasks:
            replace_handle.update_injected_data(sql)

        TimeStatistic.start("data_interactor.execute")
        result = data_interactor.execute(sql, is_reset=False)
        TimeStatistic.end("data_interactor.execute")

        if result is not None:
            self._post_process(result)
            return result.records

        return None

    def register_custom_handlers(self, handlers: List[BaseAnchorHandler]):
        if not self._is_valid_custom_handlers(handlers):
            raise RuntimeError("pilotscope is not allowed to register identical class type for custom handler")

        if not isinstance(handlers, List):
            handlers = [handlers]
        self.user_tasks += handlers

    def register_required_data(self, table_name_for_store_data, pull_execution_time=False, pull_logical_plan=False,
                               pull_physical_plan=False, pull_real_node_card=False, pull_real_node_cost=False,
                               pull_subquery_2_cards=False, pull_buffer_cache=False, pull_estimated_cost=False,
                               pull_records=False):

        if pull_execution_time:
            self.data_interactor.pull_execution_time()
        if pull_logical_plan:
            self.data_interactor.pull_logical_plan()
        if pull_physical_plan:
            self.data_interactor.pull_physical_plan()
        if pull_real_node_card:
            self.data_interactor.pull_real_node_card()
        if pull_real_node_cost:
            self.data_interactor.pull_real_node_cost()
        if pull_subquery_2_cards:
            self.data_interactor.pull_subquery_card()
        if pull_buffer_cache:
            self.data_interactor.pull_buffercache()
        if pull_estimated_cost:
            self.data_interactor.pull_estimated_cost()
        if pull_records:
            self.data_interactor.pull_record()
        self.table_name_for_store_data = table_name_for_store_data

    def register_events(self, events: List[Event]):
        if not isinstance(events, List):
            events = [events]
        self.events += events

    def _post_process(self, data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.WRITE_TABLE)
        self._store_collected_data_into_table(data)
        TimeStatistic.end(ExperimentTimeEnum.WRITE_TABLE)
        self._deal_execution_end_events()

    def _store_collected_data_into_table(self, data: PilotTransData):
        pull_anchors = extract_handlers(self.data_interactor.get_all_handlers(), True)
        column_2_value = {}
        for anchor in pull_anchors:
            if isinstance(anchor, BasePullHandler):
                anchor.prepare_data_for_writing(column_2_value, data)
            else:
                raise RuntimeError
        self.data_manager.save_data(self.table_name_for_store_data, column_2_value)

    def _deal_initial_events(self):
        pretraining_thread = None
        for event in self.events:
            if isinstance(event, PretrainingModelEvent):
                event: PretrainingModelEvent = event
                pretraining_thread = event.async_start()
            elif isinstance(event, PeriodicModelUpdateEvent):
                event: PeriodicModelUpdateEvent = event
                if event.execute_before_first_query:
                    event.process(self.db_controller, self.data_manager)
            elif isinstance(event, WorkloadBeforeEvent):
                event: WorkloadBeforeEvent = event
                event.update(self.db_controller, self.data_manager)

        # wait until finishing pretraining
        if pretraining_thread is not None and self.config.pretraining_model == TrainSwitchMode.WAIT:
            pretraining_thread.join()
        pass

    def _deal_execution_end_events(self):
        for event in self.events:
            if isinstance(event, QueryFinishEvent):
                event: QueryFinishEvent = event
                event.update(self.db_controller, self.data_manager)

    def _is_valid_custom_handlers(self, handlers):
        # return false, if there is identical class typy for the elements in handlers
        deduplicated_size = len(set([type(handler) for handler in handlers]))
        return deduplicated_size == len(handlers)
