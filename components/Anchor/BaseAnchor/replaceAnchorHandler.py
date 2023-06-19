from Anchor.AnchorEnum import AnchorEnum
from Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler


class ReplaceAnchorHandler(BaseAnchorHandler):

    def __init__(self, config) -> None:
        super().__init__(config)

    def get_additional_sqls(self):
        return []

    def add_params_to_db_core(self, params: dict):
        super().add_params_to_db_core(params)

    def user_custom_task(self, sql):
        pass

    def apply_replace_data(self, sql):
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
        for hint, value in self.key_2_value_for_hint.items():
            sqls.append(self.db_controller.get_hint_sql(hint, value))

    def add_params_to_db_core(self, params: dict):
        pass
