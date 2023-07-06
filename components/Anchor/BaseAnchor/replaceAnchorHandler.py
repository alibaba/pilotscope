from typing import List

from Anchor.AnchorEnum import AnchorEnum
from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from DBController.BaseDBController import BaseDBController
from PilotEnum import ReplaceAnchorTriggerEnum
from common.Index import Index
from PilotEnum import DatabaseEnum

class ReplaceAnchorHandler(BaseAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)
        self.trigger_type = ReplaceAnchorTriggerEnum.QUERY
        self.have_been_triggered = False

    def execute_before_comment_sql(self, db_controller: BaseDBController):
        return []

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def user_custom_task(self, sql):
        pass

    def apply_replace_data(self, sql):
        pass

    def is_can_trigger(self):
        return self.trigger_type == ReplaceAnchorTriggerEnum.QUERY or not self.have_been_triggered

    def roll_back(self, db_controller):
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

    def execute_before_comment_sql(self, db_controller: BaseDBController):
        for hint, value in self.key_2_value_for_hint.items():
            db_controller.execute(db_controller.get_hint_sql(hint, value))

    def add_params_to_db_core(self, params: dict):
        pass


class IndexAnchorHandler(ReplaceAnchorHandler):

    def __init__(self, config, indexes: List[Index] = None, drop_other=True) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.HINT_REPLACE_ANCHOR.name
        self.indexes = indexes
        self.drop_other = drop_other
        self.trigger_type = ReplaceAnchorTriggerEnum.WORKLOAD

    def apply_replace_data(self, sql):
        raise RuntimeError("IndexAnchorHandler should be extended as user task,"
                           " the modification of workload level should be dealt with event")

    def execute_before_comment_sql(self, db_controller: BaseDBController):
        if self.is_can_trigger():
            if self.drop_other:
                db_controller.drop_all_indexes()
            for index in self.indexes:
                db_controller.create_index(index.get_index_name(), index.table, index.columns)
            self.have_been_triggered = True

    def add_params_to_db_core(self, params: dict):
        pass

    def roll_back(self, db_controller):
        # self.is_can_trigger() is False if indexes has been built
        if not self.is_can_trigger():
            for index in self.indexes:
                db_controller.drop_index(index.get_index_name())
