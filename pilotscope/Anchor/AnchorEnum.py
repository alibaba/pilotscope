from enum import Enum


class AnchorEnum(Enum):
    BASE_ANCHOR = "BASE_ANCHOR",

    # push Anchors
    HINT_PUSH_ANCHOR = "HINT_PUSH_ANCHOR",
    CARD_PUSH_ANCHOR = "CARD_PUSH_ANCHOR",
    COST_PUSH_ANCHOR = "COST_PUSH_ANCHOR",
    INDEX_PUSH_ANCHOR = "INDEX_PUSH_ANCHOR",
    KNOB_PUSH_ANCHOR = "KNOB_PUSH_ANCHOR",
    COMMENT_PUSH_ANCHOR = "COMMENT_PUSH_ANCHOR"

    # pull Anchors
    RECORD_PULL_ANCHOR = "RECORD_PULL_ANCHOR",
    PHYSICAL_PLAN_PULL_ANCHOR = "PHYSICAL_PLAN_PULL_ANCHOR",
    LOGICAL_PLAN_PULL_ANCHOR = "LOGICAL_PLAN_PULL_ANCHOR",
    OPTIMIZED_SQL_PULL_ANCHOR = "OPTIMIZED_SQL_PULL_ANCHOR",
    EXECUTION_TIME_PULL_ANCHOR = "EXECUTION_TIME_PULL_ANCHOR",
    SUBQUERY_CARD_PULL_ANCHOR = "SUBQUERY_CARD_PULL_ANCHOR",
    ESTIMATED_COST_PULL_ANCHOR = "ESTIMATED_COST_PULL_ANCHOR",
    BUFFERCACHE_PULL_ANCHOR = "BUFFERCACHE_PULL_ANCHOR"

    @staticmethod
    def to_anchor_enum(anchor_name: str):
        for enum in AnchorEnum:
            if enum.name == anchor_name:
                return enum
        raise NotImplementedError("Missing the implementation of {}".format(anchor_name))
