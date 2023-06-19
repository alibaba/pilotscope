from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from Anchor.BaseAnchor.FetchAnchorHandler import RecordFetchAnchorHandler, FetchAnchorHandler
from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler
from Dao.PilotTrainDataManager import PilotTrainDataManager
from DataFetcher.PilotStateManager import PilotStateManager
from PilotConfig import PilotConfig
from PilotEnum import *
from PilotEvent import PeriodTrainingEvent, Event, PretrainingModelEvent
from PilotTransData import PilotTransData


class PilotScheduler:

    def __init__(self, config: PilotConfig) -> None:
        self.config = config
        self.training_data_save_table = None
        self.state_manager = PilotStateManager(self.config)
        self.pilot_data_manager: PilotTrainDataManager = None
        self.type_2_event = {}
        self.user_tasks = []

    def start(self):
        self._deal_initial_events()
        pass

    def simulate_db_console_offline(self, sql):
        record_handler = RecordFetchAnchorHandler(self.config)
        self.state_manager.add_anchor(record_handler.anchor_name, record_handler)

        anchor_to_handlers = self.state_manager.anchor_to_handlers

        # replace value based on user's method
        for anchor in filter(lambda a: isinstance(a, ReplaceAnchorHandler), anchor_to_handlers.values()):
            anchor.apply_replace_data(sql)

        result = self.state_manager.execute(sql)

        self._post_process(result)
        return result.records if result is not None else None

    def _post_process(self, data: PilotTransData):
        self._collect_training_data(data)
        self._deal_execution_end_events()

    def _collect_training_data(self, data: PilotTransData):

        fetch_anchors = list(
            filter(lambda anchor: isinstance(anchor, FetchAnchorHandler),
                   self.state_manager.anchor_to_handlers.values()))
        column_2_value = self._extract_data_from_anchor(fetch_anchors, data)
        self.pilot_data_manager.save_data(self.training_data_save_table, column_2_value)

    def _extract_data_from_anchor(self, fetch_anchors, data: PilotTransData):
        column_2_value = {}
        for anchor in fetch_anchors:
            if isinstance(anchor, FetchAnchorHandler):
                anchor.add_data_to_table(column_2_value, data)
            else:
                raise RuntimeError
        return column_2_value

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
            pretraining_thread.join()

    def _deal_execution_end_events(self):
        for event_type, event in self.type_2_event.items():
            if event_type == EventEnum.PERIOD_TRAIN_EVENT:
                event: PeriodTrainingEvent = event
                event.update(self.pilot_data_manager)

    def register_anchor_handler(self, anchor: BaseAnchorHandler):
        self.state_manager.add_anchor(anchor.anchor_name, anchor)

    def register_collect_data(self, training_data_save_table, state_manager: PilotStateManager):
        self.state_manager.add_anchors(state_manager.anchor_to_handlers)
        self.pilot_data_manager = PilotTrainDataManager(self.config)
        self.training_data_save_table = training_data_save_table

    def register_event(self, event_type: EventEnum, event: Event):
        self.type_2_event[event_type] = event
