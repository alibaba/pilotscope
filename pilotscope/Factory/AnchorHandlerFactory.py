from pilotscope.Anchor.BaseAnchor.PushAnchorHandler import *
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
        if anchor == AnchorEnum.CARD_PUSH_ANCHOR:
            return CardAnchorHandler(config)
        elif anchor == AnchorEnum.HINT_PUSH_ANCHOR:
            return HintAnchorHandler(config)
        elif anchor == AnchorEnum.COST_PUSH_ANCHOR:
            return CostAnchorHandler(config)
        elif anchor == AnchorEnum.INDEX_PUSH_ANCHOR:
            return IndexAnchorHandler(config)
        elif anchor == AnchorEnum.KNOB_PUSH_ANCHOR:
            return KonbAnchorHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkRecordPullAnchorHandler
            return SparkRecordPullAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkExecutionTimePullAnchorHandler
            return SparkExecutionTimePullAnchorHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkPhysicalPlanPullAnchorHandler
            return SparkPhysicalPlanPullAnchorHandler(config)
        elif anchor == AnchorEnum.OPTIMIZED_SQL_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkOptimizedSqlPullAnchorHandler
            return SparkOptimizedSqlPullAnchorHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkSubQueryCardPullAnchorHandler
            return SparkSubQueryCardPullAnchorHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkLogicalPlanPullAnchorHandler
            return SparkLogicalPlanPullAnchorHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkEstimatedCostPullAnchorHandler
            return SparkEstimatedCostPullAnchorHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkBuffercachePullAnchorHandler
            return SparkBuffercachePullAnchorHandler(config)
        else:
            raise RuntimeError()

    @classmethod
    def _get_postgresql_anchor_handle(cls, config, anchor: AnchorEnum):
        # replace
        if anchor == AnchorEnum.CARD_PUSH_ANCHOR:
            return CardAnchorHandler(config)
        elif anchor == AnchorEnum.HINT_PUSH_ANCHOR: 
            return HintAnchorHandler(config)
        elif anchor == AnchorEnum.COST_PUSH_ANCHOR:
            return CostAnchorHandler(config)
        elif anchor == AnchorEnum.INDEX_PUSH_ANCHOR:
            return IndexAnchorHandler(config)
        elif anchor == AnchorEnum.KNOB_PUSH_ANCHOR:
            return KonbAnchorHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLRecordPullAnchorHandler
            return PostgreSQLRecordPullAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLExecutionTimePullAnchorHandler
            return PostgreSQLExecutionTimePullAnchorHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLPhysicalPlanPullAnchorHandler
            return PostgreSQLPhysicalPlanPullAnchorHandler(config)
        elif anchor == AnchorEnum.OPTIMIZED_SQL_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLOptimizedSqlPullAnchorHandler
            return PostgreSQLOptimizedSqlPullAnchorHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLSubQueryCardPullAnchorHandler
            return PostgreSQLSubQueryCardPullAnchorHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLLogicalPlanPullAnchorHandler
            return PostgreSQLLogicalPlanPullAnchorHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLEstimatedCostPullAnchorHandler
            return PostgreSQLEstimatedCostPullAnchorHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLBuffercachePullAnchorHandler
            return PostgreSQLBuffercachePullAnchorHandler(config)
        else:
            raise RuntimeError()
