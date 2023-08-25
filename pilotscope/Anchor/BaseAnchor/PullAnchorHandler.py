import json

from pilotscope.Anchor.AnchorEnum import AnchorEnum
from pilotscope.Anchor.AnchorTransData import AnchorTransData
from pilotscope.Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from pilotscope.PilotEnum import FetchMethod
from pilotscope.PilotTransData import PilotTransData


class PullAnchorHandler(BaseAnchorHandler):
    def __init__(self, config):
        super().__init__(config)
        self.anchor_name: str = None
        self.fetch_method = FetchMethod.OUTER

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)
        params.update({})

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        pass

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        pass


class RecordPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.RECORD_PULL_ANCHOR.name
        self.priority = self._assign_priority()


class LogicalPlanPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR.name
        self.priority = self._assign_priority()

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.logical_plan is not None:
            column_2_value["logical_plan"] = json.dumps(data.logical_plan)


class PhysicalPlanPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR.name
        self.priority = self._assign_priority()

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.physical_plan is not None:
            column_2_value["physical_plan"] = json.dumps(data.physical_plan)


class BuffercachePullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.BUFFERCACHE_PULL_ANCHOR.name
        self.priority = self._assign_priority()

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.buffercache is not None:
            column_2_value["buffercache"] = json.dumps(data.buffercache)


class EstimatedCostPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.ESTIMATED_COST_PULL_ANCHOR.name
        self.priority = self._assign_priority()

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.estimated_cost is not None:
            column_2_value["estimated_cost"] = data.estimated_cost


class ExecutionTimePullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.EXECUTION_TIME_PULL_ANCHOR.name
        self.priority = self._assign_priority()

    def add_data_to_table(self, column_2_value, data: PilotTransData):
        if data.execution_time is not None:
            column_2_value["execution_time"] = data.execution_time


class OptimizedSqlPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.OPTIMIZED_SQL_PULL_ANCHOR.name
        self.priority = self._assign_priority()


class SubQueryCardPullAnchorHandler(PullAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR.name
        self.priority = self._assign_priority()
