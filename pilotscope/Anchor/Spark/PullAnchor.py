from pilotscope.Anchor.PostgreSQL.PullAnhor import *
from pilotscope.DBController.SparkSQLController import SparkSQLController
from pilotscope.PilotEnum import ExperimentTimeEnum
from pilotscope.common.TimeStatistic import TimeStatistic


class SparkAnchorMixin:
    pass


class SparkRecordPullAnchorHandler(RecordPullAnchorHandler, SparkAnchorMixin):
    pass


class SparkLogicalPlanPullAnchorHandler(PostgreSQLLogicalPlanPullAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.logical_plan is not None:
            return

        physical_plan = anchor_data.physical_plan

        if physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.logical_plan = anchor_data.physical_plan


class SparkPhysicalPlanPullAnchorHandler(PostgreSQLPhysicalPlanPullAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class SparkEstimatedCostPullAnchorHandler(PostgreSQLEstimatedCostPullAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller:SparkSQLController, sql, pilot_comment, anchor_data: AnchorTransData,
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


class SparkBuffercachePullAnchorHandler(PostgreSQLEstimatedCostPullAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.buffercache is not None:
            return

        if anchor_data.buffercache is None:
            anchor_data.buffercache = db_controller.get_buffercache()

        fill_data.buffercache = anchor_data.buffercache


class SparkExecutionTimePullAnchorHandler(PostgreSQLExecutionTimePullAnchorHandler, SparkAnchorMixin):
    pass


class SparkOptimizedSqlPullAnchorHandler(PostgreSQLOptimizedSqlPullAnchorHandler, SparkAnchorMixin):
    pass


class SparkSubQueryCardPullAnchorHandler(PostgreSQLSubQueryCardPullAnchorHandler, SparkAnchorMixin):
    pass
