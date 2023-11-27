from pilotscope.Anchor.BaseAnchor.BasePullHandler import *
from pilotscope.PilotEnum import ExperimentTimeEnum
from pilotscope.Common.TimeStatistic import TimeStatistic


class PostgreSQLAnchorMixin:
    def get_physical_plan(self, db_controller, sql, pilot_comment):
        return db_controller.explain_physical_plan(sql, comment=pilot_comment)


class PostgreSQLRecordPullHandler(RecordPullHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLPhysicalPlanPullHandler(PhysicalPlanPullHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = self.get_physical_plan(db_controller, sql, pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class PostgreSQLEstimatedCostPullHandler(EstimatedCostPullHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.estimated_cost is not None:
            return
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))

        if anchor_data.physical_plan is None:
            anchor_data.estimated_cost = db_controller.get_estimated_cost(sql, comment=pilot_comment)
        else:
            anchor_data.estimated_cost = anchor_data.physical_plan["Plan"]["Total Cost"]
        fill_data.estimated_cost = anchor_data.estimated_cost
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class PostgreSQLBuffercachePullHandler(BuffercachePullHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.buffercache is not None:
            return

        if anchor_data.buffercache is None:
            anchor_data.buffercache = db_controller.get_buffercache()

        fill_data.buffercache = anchor_data.buffercache


class PostgreSQLExecutionTimePullHandler(ExecutionTimePullHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLSubQueryCardPullHandler(SubQueryCardPullHandler, PostgreSQLAnchorMixin):
    pass
