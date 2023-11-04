from pilotscope.Anchor.BaseAnchor.BasePushHandler import *
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
            return CardPushHandler(config)
        elif anchor == AnchorEnum.HINT_PUSH_ANCHOR:
            return HintPushHandler(config)
        elif anchor == AnchorEnum.COST_PUSH_ANCHOR:
            return CostPushHandler(config)
        elif anchor == AnchorEnum.INDEX_PUSH_ANCHOR:
            return IndexPushHandler(config)
        elif anchor == AnchorEnum.KNOB_PUSH_ANCHOR:
            return KnobPushHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkRecordPullAnchorHandler
            return SparkRecordPullAnchorHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkExecutionTimePullHandler
            return SparkExecutionTimePullHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkPhysicalPlanPullHandler
            return SparkPhysicalPlanPullHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkSubQueryCardPullHandler
            return SparkSubQueryCardPullHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkLogicalPlanPullHandler
            return SparkLogicalPlanPullHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkEstimatedCostPullHandler
            return SparkEstimatedCostPullHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_PULL_ANCHOR:
            from pilotscope.Anchor.Spark.PullAnchor import SparkBuffercachePullHandler
            return SparkBuffercachePullHandler(config)
        else:
            raise RuntimeError()

    @classmethod
    def _get_postgresql_anchor_handle(cls, config, anchor: AnchorEnum):
        # replace
        if anchor == AnchorEnum.CARD_PUSH_ANCHOR:
            return CardPushHandler(config)
        elif anchor == AnchorEnum.HINT_PUSH_ANCHOR:
            return HintPushHandler(config)
        elif anchor == AnchorEnum.COST_PUSH_ANCHOR:
            return CostPushHandler(config)
        elif anchor == AnchorEnum.INDEX_PUSH_ANCHOR:
            return IndexPushHandler(config)
        elif anchor == AnchorEnum.KNOB_PUSH_ANCHOR:
            return KnobPushHandler(config)
        elif anchor == AnchorEnum.COMMENT_PUSH_ANCHOR:
            return CommentPushHandler(config)
        # fetch
        elif anchor == AnchorEnum.RECORD_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLRecordPullHandler
            return PostgreSQLRecordPullHandler(config)
        elif anchor == AnchorEnum.EXECUTION_TIME_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLExecutionTimePullHandler
            return PostgreSQLExecutionTimePullHandler(config)
        elif anchor == AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLPhysicalPlanPullHandler
            return PostgreSQLPhysicalPlanPullHandler(config)
        elif anchor == AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLSubQueryCardPullHandler
            return PostgreSQLSubQueryCardPullHandler(config)
        elif anchor == AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLLogicalPlanPullHandler
            return PostgreSQLLogicalPlanPullHandler(config)
        elif anchor == AnchorEnum.ESTIMATED_COST_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLEstimatedCostPullHandler
            return PostgreSQLEstimatedCostPullHandler(config)
        elif anchor == AnchorEnum.BUFFERCACHE_PULL_ANCHOR:
            from pilotscope.Anchor.PostgreSQL.PullAnhor import PostgreSQLBuffercachePullHandler
            return PostgreSQLBuffercachePullHandler(config)
        else:
            raise RuntimeError()
