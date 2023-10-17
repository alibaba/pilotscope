from pilotscope.Anchor.PostgreSQL.PullAnhor import *
from pilotscope.DBController.SparkSQLController import SparkSQLController
from pilotscope.PilotEnum import ExperimentTimeEnum
from pilotscope.Common.TimeStatistic import TimeStatistic


class SparkAnchorMixin:
    pass


class SparkRecordPullAnchorHandler(RecordPullHandler, SparkAnchorMixin):
    pass


class SparkLogicalPlanPullHandler(PostgreSQLLogicalPlanPullHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.logical_plan is not None:
            return

        if anchor_data.logical_plan is None:
            anchor_data.logical_plan = db_controller.explain_logical_plan(sql, comment=pilot_comment)

        fill_data.logical_plan = anchor_data.logical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class SparkPhysicalPlanPullHandler(PostgreSQLPhysicalPlanPullHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class SparkEstimatedCostPullHandler(PostgreSQLEstimatedCostPullHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller: SparkSQLController, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        raise NotImplementedError
        # TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        # if fill_data.estimated_cost is not None:
        #     return
        #
        # if anchor_data.logical_plan is None:
        #     anchor_data.logical_plan = db_controller.explain_logical_plan(sql, comment=pilot_comment)
        #
        # if anchor_data.estimated_cost is None:
        #     pass
        #
        # fill_data.estimated_cost = anchor_data.physical_plan["Plan"]["Total Cost"]
        # TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class SparkBuffercachePullHandler(PostgreSQLEstimatedCostPullHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.buffercache is not None:
            return

        if anchor_data.buffercache is None:
            anchor_data.buffercache = db_controller.get_buffercache()

        fill_data.buffercache = anchor_data.buffercache


class SparkExecutionTimePullHandler(PostgreSQLExecutionTimePullHandler, SparkAnchorMixin):
    pass


class SparkSubQueryCardPullHandler(PostgreSQLSubQueryCardPullHandler, SparkAnchorMixin):
    pass
