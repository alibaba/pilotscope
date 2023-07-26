from Anchor.BaseAnchor.FetchAnchorHandler import *
from PilotEnum import ExperimentTimeEnum
from common.TimeStatistic import TimeStatistic


class PostgreSQLAnchorMixin:
    pass


class PostgreSQLRecordFetchAnchorHandler(RecordFetchAnchorHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLLogicalPlanFetchAnchorHandler(LogicalPlanFetchAnchorHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.logical_plan is not None:
            return

        physical_plan = anchor_data.physical_plan

        if physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.logical_plan = anchor_data.physical_plan


class PostgreSQLPhysicalPlanFetchAnchorHandler(PhysicalPlanFetchAnchorHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class PostgreSQLEstimatedCostFetchAnchorHandler(EstimatedCostFetchAnchorHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.estimated_cost is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.estimated_cost = anchor_data.physical_plan["Plan"]["Total Cost"]
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class PostgreSQLBuffercacheFetchAnchorHandler(BuffercacheFetchAnchorHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.buffercache is not None:
            return

        if anchor_data.buffercache is None:
            anchor_data.buffercache = db_controller.get_buffercache()

        fill_data.buffercache = anchor_data.buffercache


class PostgreSQLExecutionTimeFetchAnchorHandler(ExecutionTimeFetchAnchorHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLOptimizedSqlFetchAnchorHandler(OptimizedSqlFetchAnchorHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLSubQueryCardFetchAnchorHandler(SubQueryCardFetchAnchorHandler, PostgreSQLAnchorMixin):
    pass
