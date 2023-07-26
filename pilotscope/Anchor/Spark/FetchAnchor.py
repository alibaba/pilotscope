from Anchor.PostgreSQL.FetchAnhor import *
from DBController.SparkSQLController import SparkSQLController
from PilotEnum import ExperimentTimeEnum
from common.TimeStatistic import TimeStatistic


class SparkAnchorMixin:
    pass


class SparkRecordFetchAnchorHandler(RecordFetchAnchorHandler, SparkAnchorMixin):
    pass


class SparkLogicalPlanFetchAnchorHandler(PostgreSQLLogicalPlanFetchAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.logical_plan is not None:
            return

        physical_plan = anchor_data.physical_plan

        if physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.logical_plan = anchor_data.physical_plan


class SparkPhysicalPlanFetchAnchorHandler(PostgreSQLPhysicalPlanFetchAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        TimeStatistic.start(ExperimentTimeEnum.get_anchor_key(self.anchor_name))
        if fill_data.physical_plan is not None:
            return

        if anchor_data.physical_plan is None:
            anchor_data.physical_plan = db_controller.explain_physical_plan(sql, comment=pilot_comment)

        fill_data.physical_plan = anchor_data.physical_plan
        TimeStatistic.end(ExperimentTimeEnum.get_anchor_key(self.anchor_name))


class SparkEstimatedCostFetchAnchorHandler(PostgreSQLEstimatedCostFetchAnchorHandler, SparkAnchorMixin):

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


class SparkBuffercacheFetchAnchorHandler(PostgreSQLEstimatedCostFetchAnchorHandler, SparkAnchorMixin):

    def fetch_from_outer(self, db_controller, sql, pilot_comment, anchor_data: AnchorTransData,
                         fill_data: PilotTransData):
        if fill_data.buffercache is not None:
            return

        if anchor_data.buffercache is None:
            anchor_data.buffercache = db_controller.get_buffercache()

        fill_data.buffercache = anchor_data.buffercache


class SparkExecutionTimeFetchAnchorHandler(PostgreSQLExecutionTimeFetchAnchorHandler, SparkAnchorMixin):
    pass


class SparkOptimizedSqlFetchAnchorHandler(PostgreSQLOptimizedSqlFetchAnchorHandler, SparkAnchorMixin):
    pass


class SparkSubQueryCardFetchAnchorHandler(PostgreSQLSubQueryCardFetchAnchorHandler, SparkAnchorMixin):
    pass
