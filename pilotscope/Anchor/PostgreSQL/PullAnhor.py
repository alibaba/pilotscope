from pilotscope.Anchor.BaseAnchor.BasePullHandler import *


class PostgreSQLAnchorMixin:
    def get_physical_plan(self, db_controller, sql, pilot_comment):
        return db_controller.explain_physical_plan(sql, comment=pilot_comment)


class PostgreSQLRecordPullHandler(RecordPullHandler, PostgreSQLAnchorMixin):
    pass


class PostgreSQLPhysicalPlanPullHandler(PhysicalPlanPullHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = self.get_physical_plan(db_controller, sql, pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan


class PostgreSQLEstimatedCostPullHandler(EstimatedCostPullHandler, PostgreSQLAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.estimated_cost is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.estimated_cost = db_controller.get_estimated_cost(sql, comment=pilot_comment)
        else:
            anchor_data.estimated_cost = anchor_data.physical_plan["Plan"]["Total Cost"]
        fill_data.estimated_cost = anchor_data.estimated_cost


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

    def __init__(self, config) -> None:
        super().__init__(config)
        self.enable_parameterized_subquery = False

    def add_trans_params(self, params: dict):
        super().add_trans_params(params)
        params.update({"enable_parameterized_subquery": self.enable_parameterized_subquery})
