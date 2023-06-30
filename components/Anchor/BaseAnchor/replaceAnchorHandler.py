from typing import List

from Anchor.AnchorEnum import AnchorEnum
from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from PilotEnum import ReplaceAnchorTriggerEnum
from common.Index import Index
from PilotEnum import DatabaseEnum
from DBController.PostgreSQLController import PostgreSQLController

class ReplaceAnchorHandler(BaseAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.trigger_type = ReplaceAnchorTriggerEnum.QUERY
        self.have_been_triggered = False

    def get_additional_sqls(self):
        return []

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def user_custom_task(self, sql):
        pass

    def apply_replace_data(self, sql):
        pass

    def is_can_trigger(self):
        return self.trigger_type == ReplaceAnchorTriggerEnum.QUERY or not self.have_been_triggered

    def roll_back(self):
        pass


class CardAnchorHandler(ReplaceAnchorHandler):

    def __init__(self, config, subquery_2_card: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.CARD_REPLACE_ANCHOR.name
        self.subquery_2_card = subquery_2_card

    def apply_replace_data(self, sql):
        self.subquery_2_card = self.user_custom_task(sql)

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)
        params.update({"subquery": list(self.subquery_2_card.keys()), "card": list(self.subquery_2_card.values())})


class CostAnchorHandler(ReplaceAnchorHandler):

    def __init__(self, config, subplan_2_cost: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.COST_REPLACE_ANCHOR.name
        self.subplan_2_cost = subplan_2_cost

    def apply_replace_data(self, sql):
        self.subplan_2_cost = self.user_custom_task(sql)

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)
        params.update({"subplan": list(self.subplan_2_cost.keys()), "cost": list(self.subplan_2_cost.values())})


class HintAnchorHandler(ReplaceAnchorHandler):

    def __init__(self, config, key_2_value_for_hint: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.HINT_REPLACE_ANCHOR.name
        self.key_2_value_for_hint = key_2_value_for_hint

    def apply_replace_data(self, sql):
        self.key_2_value_for_hint = self.user_custom_task(sql)

    def get_additional_sqls(self):
        sqls = []
        if self.config.db_type == DatabaseEnum.POSTGRESQL:
            now_get_hint_sql = PostgreSQLController.get_hint_sql
        else:
            raise NotImplementedError
        for hint, value in self.key_2_value_for_hint.items():
            sqls.append(now_get_hint_sql(hint, value))
        return sqls

    def add_params_to_db_core(self, params: dict):
        pass


class IndexAnchorHandler(ReplaceAnchorHandler):

    def __init__(self, config, indexes: List[Index], drop_other=True) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.HINT_REPLACE_ANCHOR.name
        self.indexes = indexes
        self.drop_other = drop_other
        self.trigger_type = ReplaceAnchorTriggerEnum.WORKLOAD

    def apply_replace_data(self, sql):
        if self.is_can_trigger():
            self.indexes = self.user_custom_task(sql)

    def get_additional_sqls(self):
        if self.is_can_trigger():
            sqls = []
            for index in self.indexes:
                sqls.append(self.db_controller.get_create_index_sql(index))
            self.have_been_triggered = True

    def add_params_to_db_core(self, params: dict):
        pass

    def roll_back(self):
        for index in self.indexes:
            self.db_controller.drop_index(index.get_index_name())
