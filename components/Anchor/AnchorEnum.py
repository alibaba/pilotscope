from enum import Enum


class AnchorEnum(Enum):
    BASE_ANCHOR = "BASE_ANCHOR",

    HINT_REPLACE_ANCHOR = "HINT_REPLACE_ANCHOR",
    CARD_REPLACE_ANCHOR = "CARD_REPLACE_ANCHOR",
    COST_REPLACE_ANCHOR = "COST_REPLACE_ANCHOR",

    RECORD_FETCH_ANCHOR = "RECORD_FETCH_ANCHOR",
    PHYSICAL_PLAN_FETCH_ANCHOR = "PHYSICAL_PLAN_FETCH_ANCHOR",
    LOGICAL_PLAN_FETCH_ANCHOR = "LOGICAL_PLAN_FETCH_ANCHOR",
    OPTIMIZED_SQL_FETCH_ANCHOR = "OPTIMIZED_SQL_FETCH_ANCHOR",
    EXECUTION_TIME_FETCH_ANCHOR = "EXECUTION_TIME_FETCH_ANCHOR",
    SUBQUERY_CARD_FETCH_ANCHOR = "SUBQUERY_CARD_FETCH_ANCHOR",

    @staticmethod
    def to_anchor_enum(anchor_name: str):
        for enum in AnchorEnum:
            if enum.name == anchor_name:
                return enum
        raise RuntimeError
