from Anchor.BaseAnchor.replaceAnchorHandler import *
from Anchor.PostgreSQL.FetchAnhor import *
from PilotConfig import PilotConfig
from PilotEnum import DatabaseEnum


class AnchorHandlerFactory:
    @classmethod
    def get_anchor_handler(cls, config: PilotConfig, anchor: AnchorEnum):

        if config.db_type == DatabaseEnum.POSTGRESQL:
            return cls._get_postgresql_anchor_handle(config, anchor)
        else:
            raise RuntimeError()

    @classmethod
    def _get_postgresql_anchor_handle(cls, config, anchor: AnchorEnum):
        # replace
        if anchor == AnchorEnum.CARD_REPLACE_ANCHOR:
            return CardAnchorHandler(config)
        elif anchor == AnchorEnum.HINT_REPLACE_ANCHOR:
            return HintAnchorHandler(config)
        elif anchor == AnchorEnum.COST_REPLACE_ANCHOR:
            return CostAnchorHandler(config)
        elif anchor == AnchorEnum.INDEX_REPLACE_ANCHOR:
            return IndexAnchorHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_FETCH_ANCHOR:
            return PostgreSQLRecordFetchAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR:
            return PostgreSQLExecutionTimeFetchAnchorHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR:
            return PostgreSQLPhysicalPlanFetchAnchorHandler(config)
        elif anchor == AnchorEnum.OPTIMIZED_SQL_FETCH_ANCHOR:
            return PostgreSQLOptimizedSqlFetchAnchorHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR:
            return PostgreSQLSubQueryCardFetchAnchorHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_FETCH_ANCHOR:
            return PostgreSQLLogicalPlanFetchAnchorHandler(config)
<<<<<<< HEAD
        elif anchor == AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR:
            return PostgreSQLEstimatedCostFetchAnchorHandler(config)
=======
        elif anchor == AnchorEnum.BUFFERCACHE_FETCH_ANCHOR:
            return PostgreSQLBuffercacheFetchAnchorHandler(config)
>>>>>>> feat: Example BAO. Anchor BuffercacheFetch
        else:
            raise RuntimeError()
