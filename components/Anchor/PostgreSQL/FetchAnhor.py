from Anchor.BaseAnchor.FetchAnchorHandler import *


class PostgreSQLAnchorMixin:
    pass


class PostgreSQLRecordFetchAnchorHandler(RecordFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)


class PostgreSQLLogicalPlanFetchAnchorHandler(LogicalPlanFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.LOGICAL_PLAN_FETCH_ANCHOR.name

    def fetch_from_outer(self, sql, pilot_comment, anchor_data: AnchorTransData, fill_data: PilotTransData):
        if fill_data.logical_plan is not None:
            return

        physical_plan = anchor_data.physical_plan
        execution_plan = anchor_data.execution_plan

        if physical_plan is None and execution_plan is None:
            anchor_data.physical_plan = self.db_controller.explain_physical_plan(sql, comment=pilot_comment)
        else:
            return physical_plan if physical_plan else execution_plan

        fill_data.logical_plan = anchor_data.physical_plan


class PostgreSQLPhysicalPlanFetchAnchorHandler(PhysicalPlanFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR.name

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def fetch_from_outer(self, sql, pilot_comment, anchor_data: AnchorTransData, fill_data: PilotTransData):
        if fill_data.physical_plan is not None:
            return

        if anchor_data.execution_plan is None:
            anchor_data.physical_plan = self.db_controller.explain_physical_plan(sql, comment=pilot_comment)
        else:
            anchor_data.physical_plan = anchor_data.execution_plan
        fill_data.physical_plan = anchor_data.physical_plan


class PostgreSQLExecutionTimeFetchAnchorHandler(ExecutionTimeFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR.name


class PostgreSQLOptimizedSqlFetchAnchorHandler(OptimizedSqlFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.OPTIMIZED_SQL_FETCH_ANCHOR.name


class PostgreSQLSubQueryCardFetchAnchorHandler(SubQueryCardFetchAnchorHandler, PostgreSQLAnchorMixin):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR.name
