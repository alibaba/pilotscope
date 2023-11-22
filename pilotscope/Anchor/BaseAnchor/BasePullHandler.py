import json

from pilotscope.Anchor.AnchorEnum import AnchorEnum
from pilotscope.Anchor.AnchorTransData import AnchorTransData
from pilotscope.Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from pilotscope.PilotEnum import FetchMethod
from pilotscope.PilotTransData import PilotTransData


class BasePullHandler(BaseAnchorHandler):
    def __init__(self, config):
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER

    def add_trans_params(self, params: dict):
        super().add_trans_params(params)

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        """
        The pilotscope support two type of methods to collect the data required by users. The first method called "inner"
         collect data when submitting SQl query to execute. The second method called "outer" collect data with
         another new execution for current SQL query, which is often used when database provide an easy-to-use and
         low-cost API for the data collection.

        :param db_controller:
        :param sql:
        :param pilot_comment:
        :param anchor_data:
        :param fill_data:
        :return:
        """
        pass

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        """
        Add the collected data into the "column_2_value" from input parameter "data".
        
        :param column_2_value: Saving the data expected to be written into database.
        :param data: All collected data in the execution process of current SQL query.
        :return:
        """
        pass


class RecordPullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.RECORD_PULL_ANCHOR.name


class LogicalPlanPullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.logical_plan is not None:
            column_2_value["logical_plan"] = json.dumps(data.logical_plan)


class PhysicalPlanPullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.physical_plan is not None:
            column_2_value["physical_plan"] = json.dumps(data.physical_plan)


class BuffercachePullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.BUFFERCACHE_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.buffercache is not None:
            column_2_value["buffercache"] = json.dumps(data.buffercache)


class EstimatedCostPullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.OUTER
        self.anchor_name = AnchorEnum.ESTIMATED_COST_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.estimated_cost is not None:
            column_2_value["estimated_cost"] = data.estimated_cost


class ExecutionTimePullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.EXECUTION_TIME_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.execution_time is not None:
            column_2_value["execution_time"] = data.execution_time


class SubQueryCardPullHandler(BasePullHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.fetch_method = FetchMethod.INNER
        self.anchor_name = AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR.name

    def prepare_data_for_writing(self, column_2_value, data: PilotTransData):
        if data.execution_time is not None:
            column_2_value["subquery_to_card"] = data.subquery_2_card
