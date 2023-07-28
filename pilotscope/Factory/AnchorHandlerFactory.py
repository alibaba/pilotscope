from pilotscope.Anchor.BaseAnchor.replaceAnchorHandler import *
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import DatabaseEnum


class AnchorHandlerFactory:
    @classmethod
    def get_anchor_handler(cls, config: PilotConfig, anchor: AnchorEnum):

        if config.db_type == DatabaseEnum.POSTGRESQL:
            return cls._get_postgresql_anchor_handle(config, anchor)
        elif config.db_type == DatabaseEnum.SPARK:
            return cls._get_spark_anchor_handle(config, anchor)
        else:
            raise RuntimeError()

    @classmethod
    def _get_spark_anchor_handle(cls, config, anchor: AnchorEnum):
        # replace
        if anchor == AnchorEnum.CARD_REPLACE_ANCHOR:
            return CardAnchorHandler(config)
        elif anchor == AnchorEnum.HINT_REPLACE_ANCHOR:
            return HintAnchorHandler(config)
        elif anchor == AnchorEnum.COST_REPLACE_ANCHOR:
            return CostAnchorHandler(config)
        elif anchor == AnchorEnum.INDEX_REPLACE_ANCHOR:
            return IndexAnchorHandler(config)
        elif anchor == AnchorEnum.KNOB_REPLACE_ANCHOR:
            return KonbAnchorHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkRecordFetchAnchorHandler
            return SparkRecordFetchAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkExecutionTimeFetchAnchorHandler
            return SparkExecutionTimeFetchAnchorHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkPhysicalPlanFetchAnchorHandler
            return SparkPhysicalPlanFetchAnchorHandler(config)
        elif anchor == AnchorEnum.OPTIMIZED_SQL_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkOptimizedSqlFetchAnchorHandler
            return SparkOptimizedSqlFetchAnchorHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkSubQueryCardFetchAnchorHandler
            return SparkSubQueryCardFetchAnchorHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkLogicalPlanFetchAnchorHandler
            return SparkLogicalPlanFetchAnchorHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkEstimatedCostFetchAnchorHandler
            return SparkEstimatedCostFetchAnchorHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_FETCH_ANCHOR:
            from pilotscope.Anchor.Spark.FetchAnchor import SparkBuffercacheFetchAnchorHandler
            return SparkBuffercacheFetchAnchorHandler(config)
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
        elif anchor == AnchorEnum.KNOB_REPLACE_ANCHOR:
            return KonbAnchorHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLRecordFetchAnchorHandler
            return PostgreSQLRecordFetchAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLExecutionTimeFetchAnchorHandler
            return PostgreSQLExecutionTimeFetchAnchorHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLPhysicalPlanFetchAnchorHandler
            return PostgreSQLPhysicalPlanFetchAnchorHandler(config)
        elif anchor == AnchorEnum.OPTIMIZED_SQL_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLOptimizedSqlFetchAnchorHandler
            return PostgreSQLOptimizedSqlFetchAnchorHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLSubQueryCardFetchAnchorHandler
            return PostgreSQLSubQueryCardFetchAnchorHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLLogicalPlanFetchAnchorHandler
            return PostgreSQLLogicalPlanFetchAnchorHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLEstimatedCostFetchAnchorHandler
            return PostgreSQLEstimatedCostFetchAnchorHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_FETCH_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.FetchAnhor import PostgreSQLBuffercacheFetchAnchorHandler
            return PostgreSQLBuffercacheFetchAnchorHandler(config)
        else:
            raise RuntimeError()
