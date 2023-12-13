from typing import List

from pilotscope.Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from pilotscope.Anchor.BaseAnchor.BasePullHandler import RecordPullHandler, BasePullHandler
from pilotscope.Anchor.BaseAnchor.BasePushHandler import BasePushHandler
from pilotscope.Common.Util import extract_handlers
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotEnum import *
from pilotscope.PilotEvent import *
from pilotscope.PilotTransData import PilotTransData


# noinspection PyProtectedMember
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
        """
        Initialize the scheduler for enabling the AI4DB algorithms, triggering the registered events and others.
        This function should be called before executing any sql and after registering all the required data and events.
        """
        self._deal_initial_events()

    def execute(self, sql):
        """
        The function will finish the following tasks:

        1. execute a sql using the registered AI4DB algorithms.

        2. save the collected data into the specific table

        3. try to trigger the registered events

        :param sql: a sql to be executed
        :return: the related records of the sql
        """
        data_interactor = self.data_interactor

        # add recordPullAnchor
        record_handler = RecordPullHandler(self.config)
        data_interactor._add_anchor(record_handler.anchor_name, record_handler)

        # add all replace anchors from user
        data_interactor._add_anchors(self.user_tasks)

        # replace value based on user's method

        for replace_handle in self.user_tasks:
            replace_handle.update_injected_data(sql)

        result = data_interactor.execute(sql, is_reset=False)

        if result is not None:
            self._post_process(result)
            return result.records

        return None

    def register_custom_handlers(self, handlers: List[BaseAnchorHandler]):
        """
        Register custom AI4DB handlers

        :param handlers: a list of custom handlers
        """
        if not self._is_valid_custom_handlers(handlers):
            raise RuntimeError("pilotscope is not allowed to register identical class type for custom handler")

        if not isinstance(handlers, List):
            handlers = [handlers]
        self.user_tasks += handlers

    def register_required_data(self, table_name_for_store_data, pull_execution_time=False, pull_physical_plan=False,
                               pull_subquery_2_cards=False, pull_buffer_cache=False, pull_estimated_cost=False):
        """
        Register data need to collect when execute a sql

        :param table_name_for_store_data: the table name for storing the collected data
        :param pull_execution_time: the execution time of a sql
        :param pull_physical_plan: the physical plan of a sql
        :param pull_subquery_2_cards: the sub-plan queries and their cardinality of a sql
        :param pull_buffer_cache: the buffer cache of table after executing a sql
        :param pull_estimated_cost: the estimated cost of a sql
        :return:
        """
        if pull_execution_time:
            self.data_interactor.pull_execution_time()
        if pull_physical_plan:
            self.data_interactor.pull_physical_plan()
        if pull_subquery_2_cards:
            self.data_interactor.pull_subquery_card()
        if pull_buffer_cache:
            self.data_interactor.pull_buffercache()
        if pull_estimated_cost:
            self.data_interactor.pull_estimated_cost()
        self.table_name_for_store_data = table_name_for_store_data

    def register_events(self, events: List[Event]):
        """
        Register events into scheduler.

        :param events: the events to be registered
        """
        if not isinstance(events, List):
            events = [events]
        self.events += events

    def _post_process(self, data: PilotTransData):
        self._store_collected_data_into_table(data)
        self._deal_execution_end_events()

    def _store_collected_data_into_table(self, data: PilotTransData):
        pull_anchors = extract_handlers(self.data_interactor._get_all_handlers(), True)
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
                pretraining_thread = event._async_start()
            elif isinstance(event, PeriodicModelUpdateEvent):
                event: PeriodicModelUpdateEvent = event
                if event.execute_before_first_query:
                    event.process(self.db_controller, self.data_manager)
            elif isinstance(event, WorkloadBeforeEvent):
                event: WorkloadBeforeEvent = event
                event._update(self.db_controller, self.data_manager)

        # wait until finishing pretraining
        if pretraining_thread is not None and self.config.pretraining_model == TrainSwitchMode.WAIT:
            pretraining_thread.join()
        pass

    def _deal_execution_end_events(self):
        for event in self.events:
            if isinstance(event, QueryFinishEvent):
                event: QueryFinishEvent = event
                event._update(self.db_controller, self.data_manager)

    def _is_valid_custom_handlers(self, handlers):
        # return false, if there is identical class typy for the elements in handlers
        deduplicated_size = len(set([type(handler) for handler in handlers]))
        return deduplicated_size == len(handlers)
