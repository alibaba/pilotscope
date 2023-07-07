import json

from Anchor.AnchorEnum import AnchorEnum
from Anchor.AnchorTransData import AnchorTransData
from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from PilotEnum import FetchMethod
from PilotTransData import PilotTransData

name_2_priority = {
    AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR.name: 0,
    AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR.name: 1,
    "OTHER": 9
}


class FetchAnchorHandler(BaseAnchorHandler):
    def __init__(self, config):
        super().__init__(config)
        self.anchor_name: str = None
        self.fetch_method = FetchMethod.OUTER
        self.priority = self._assign_priority()

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)
        params.update({})

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        pass

    def _assign_priority(self):
        if self.anchor_name in name_2_priority:
            return name_2_priority[self.anchor_name]
        else:
            return name_2_priority["OTHER"]

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        pass


class RecordFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.RECORD_FETCH_ANCHOR.name


class LogicalPlanFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.LOGICAL_PLAN_FETCH_ANCHOR.name

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.logical_plan is not None:
            column_2_value["logical_plan"] = json.dumps(data.logical_plan)


class PhysicalPlanFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR.name

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.physical_plan is not None:
            column_2_value["physical_plan"] = json.dumps(data.physical_plan)


class BuffercacheFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.BUFFERCACHE_FETCH_ANCHOR.name

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.buffercache is not None:
            column_2_value["buffercache"] = json.dumps(data.buffercache)


class EstimatedCostFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR.name

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.estimated_cost is not None:
            column_2_value["estimated_cost"] = data.estimated_cost


class ExecutionTimeFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR.name

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.execution_time is not None:
            column_2_value["execution_time"] = data.execution_time


class OptimizedSqlFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.OPTIMIZED_SQL_FETCH_ANCHOR.name


class SubQueryCardFetchAnchorHandler(FetchAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR.name
