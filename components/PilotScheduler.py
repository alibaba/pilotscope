from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from Anchor.BaseAnchor.FetchAnchorHandler import RecordFetchAnchorHandler, FetchAnchorHandler
from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEnum import *
from PilotEvent import PeriodTrainingEvent, Event, PretrainingModelEvent
from PilotTransData import PilotTransData
from common.Util import extract_anchor_handlers, extract_table_data_from_anchor


class PilotScheduler:

    def __init__(self, config: PilotConfig) -> None:
        self.config = config
        self.training_data_save_table = None
        self.collect_data_state_manager: PilotStateManager = None
        self.pilot_data_manager: PilotTrainDataManager = PilotTrainDataManager(self.config)
        self.type_2_event = {}
        self.user_tasks = []

    def start(self):
        self._deal_initial_events()
        pass

    def simulate_db_console(self, sql):
        state_manager = PilotStateManager(self.config)

        # add anchor for collecting data to training model
        state_manager.add_anchors(self.collect_data_state_manager.anchor_to_handlers.values())

        # add recordFetchAnchor
        record_handler = RecordFetchAnchorHandler(self.config)
        state_manager.add_anchor(record_handler.anchor_name, record_handler)

        # add all replace anchors from user
        state_manager.add_anchors(self.user_tasks)

        # replace value based on user's method
        for replace_handle in self.user_tasks:
            replace_handle.apply_replace_data(sql)

        result = state_manager.execute(sql, enable_clear=False)

        self._post_process(result)
        return result.records if result is not None else None

    def _post_process(self, data: PilotTransData):
        self._collect_training_data(data)
        self._deal_execution_end_events()

    def _collect_training_data(self, data: PilotTransData):
        fetch_anchors = extract_anchor_handlers(self.collect_data_state_manager.anchor_to_handlers.values(), True)
        column_2_value = extract_table_data_from_anchor(fetch_anchors, data)
        self.pilot_data_manager.save_data(self.training_data_save_table, column_2_value)

    def _deal_initial_events(self):
        pretraining_thread = None
        for event_type, event in self.type_2_event.items():
            if event_type == EventEnum.PRETRAINING_EVENT:
                event: PretrainingModelEvent = event
                pretraining_thread = event.async_start()
            elif event_type == EventEnum.PERIODIC_COLLECTION_EVENT:
                pass

        # wait until finishing pretraining
        if pretraining_thread is not None and self.config.pretraining_model == TrainSwitchMode.WAIT:
            pretraining_thread.join(200)
        pass

    def _deal_execution_end_events(self):
        for event_type, event in self.type_2_event.items():
            if event_type == EventEnum.PERIOD_TRAIN_EVENT:
                event: PeriodTrainingEvent = event
                event.update(self.pilot_data_manager)

    def register_anchor_handler(self, anchor: BaseAnchorHandler):
        self.user_tasks.append(anchor)

    def register_collect_data(self, training_data_save_table, state_manager: PilotStateManager):
        self.collect_data_state_manager = state_manager
        self.training_data_save_table = training_data_save_table

    def register_event(self, event_type: EventEnum, event: Event):
        self.type_2_event[event_type] = event
