from typing import List

from pilotscope.Anchor.AnchorEnum import AnchorEnum
from pilotscope.Anchor.BaseAnchor.BaseAnchorHandler import BaseAnchorHandler
from pilotscope.Common.Index import Index
from pilotscope.DBController.BaseDBController import BaseDBController
from pilotscope.PilotEnum import PushHandlerTriggerLevelEnum


class BasePushHandler(BaseAnchorHandler):
    """
    Each type of "PushHandler" is responsible for the functionality implementation of a type of data that
    will be set to database.
    The functionality include set data into database by adding parameters(e.g., cardinality estimation)
    or execute some SQL queries in advance (e.g., query hint), roll back database into origin after finishing execution.
    """

    def __init__(self, config) -> None:
        """
        Initialize the PushHandler.

        :param config: the configuration of PilotScope
        """
        super().__init__(config)
        self.trigger_level = PushHandlerTriggerLevelEnum.QUERY
        self.have_been_triggered = False

    def _exec_commands_before_sql(self, db_controller: BaseDBController):
        """
        Execute some commands before committing query into database.
        """
        return []

    def _add_trans_params(self, params: dict):
        """
        Add some params (e.g., data) into transmission protocols such than the database can set data.

        :param params: a dict that will be transmitted to database
        """
        super()._add_trans_params(params)

    def acquire_injected_data(self, sql):
        """
        The users should implement the function to return their data from ML algorithms. The pilotscope will set these data
        into database automatically when execute the current SQL query.

        :param sql: current SQL query
        :return: the data that will be set into database when execute the SQL query. The type of each data is dependent on the specific the type of "PushHandler". The user can refer to the specific subclass of "BasePushHandler" for more details.
        """
        pass

    def _update_injected_data(self, sql):
        """
        Collecting and saving the data from "acquire_injected_data" into variable of class.

        :param sql:
        :return:
        """
        pass

    def _can_trigger(self):
        """
        Deciding whether trigger data injection for each SQL query. For the PushHandler of query level, it is always
        true, but for the workload level's (e.g., index and knob), it will be true for the first SQL query,
        and false for remain queries.

        :return:
        """
        return self.trigger_level == PushHandlerTriggerLevelEnum.QUERY or not self.have_been_triggered

    def _roll_back(self, db_controller):
        pass


class CardPushHandler(BasePushHandler):

    def __init__(self, config, subquery_2_card: dict = None, enable_parameterized_subquery=False) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.CARD_PUSH_ANCHOR.name
        self.subquery_2_card = subquery_2_card
        self.enable_parameterized_subquery = enable_parameterized_subquery

    def acquire_injected_data(self, sql):
        """
        The users should implement the function to return their data from cardinality estimation algorithms.
        The pilotscope will set these data into database automatically when execute the current SQL query.

        :param sql: current SQL query
        :return: A dict where the key is the subquery and the value is the cardinality estimation of the subquery.
        """
        pass

    def _update_injected_data(self, sql):
        self.subquery_2_card = self.acquire_injected_data(sql)

    def _add_trans_params(self, params: dict):
        super()._add_trans_params(params)
        params.update({"subquery": list(self.subquery_2_card.keys()), "card": list(self.subquery_2_card.values()),
                       "enable_parameterized_subquery": self.enable_parameterized_subquery})


class CostPushHandler(BasePushHandler):

    def __init__(self, config, subplan_2_cost: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.COST_PUSH_ANCHOR.name
        self.subplan_2_cost = subplan_2_cost

    def _update_injected_data(self, sql):
        self.subplan_2_cost = self.acquire_injected_data(sql)

    def _add_trans_params(self, params: dict):
        super()._add_trans_params(params)
        params.update({"subplan": list(self.subplan_2_cost.keys()), "cost": list(self.subplan_2_cost.values())})


class HintPushHandler(BasePushHandler):

    def __init__(self, config, key_2_value_for_hint: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.HINT_PUSH_ANCHOR.name
        self.key_2_value_for_hint = key_2_value_for_hint

    def acquire_injected_data(self, sql):
        """
        The users should implement the function to return their data from hint selection algorithms.
        The pilotscope will set these data into database automatically when execute the current SQL query.

        :param sql: current SQL query
        :return: A dict where the key is the hint name and the value is the value of the hint.
        """
        pass

    def _update_injected_data(self, sql):
        self.key_2_value_for_hint = self.acquire_injected_data(sql)

    def _exec_commands_before_sql(self, db_controller: BaseDBController):
        for hint, value in self.key_2_value_for_hint.items():
            db_controller.set_hint(hint, value)

    def _add_trans_params(self, params: dict):
        # the empty function is meaningful for removing all params from superclass.
        pass


class CommentPushHandler(BasePushHandler):

    def __init__(self, config, comment_str="") -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.COMMENT_PUSH_ANCHOR.name
        self.comment_str = comment_str

    def _update_injected_data(self, sql):
        self.comment_str = self.acquire_injected_data(sql)

    def _add_trans_params(self, params: dict):
        # the empty function is meaningful for removing all params from superclass.
        pass

    def acquire_injected_data(self, sql):
        """
        The users should implement the function to return their data from ML algorithms.
        The pilotscope will set these data into database automatically when execute the current SQL query.

        :param sql: current SQL query
        :return: A comment string that will be added before the SQL query. This can be used to add `pg_hint_plan` comments, and apply join order alrogithms.
        """
        pass


class KnobPushHandler(BasePushHandler):

    def __init__(self, config, key_2_value_for_knob: dict = None) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.KNOB_PUSH_ANCHOR.name
        self.key_2_value_for_knob = key_2_value_for_knob

    def _update_injected_data(self, sql):
        self.key_2_value_for_knob = self.acquire_injected_data(sql)

    def _exec_commands_before_sql(self, db_controller: BaseDBController):
        if self._can_trigger():
            db_controller.write_knob_to_file(self.key_2_value_for_knob)
            db_controller.restart()
            self.have_been_triggered = True

    def _add_trans_params(self, params: dict):
        # the empty function is meaningful for removing all params from superclass.
        pass


class IndexPushHandler(BasePushHandler):

    def __init__(self, config, indexes: List[Index] = None, drop_other=True) -> None:
        super().__init__(config)
        self.anchor_name = AnchorEnum.INDEX_PUSH_ANCHOR.name
        self.indexes = indexes
        self.drop_other = drop_other
        self.trigger_type = PushHandlerTriggerLevelEnum.WORKLOAD

    def _update_injected_data(self, sql):
        raise RuntimeError("IndexPushHandler should be extended by the user. "
                           "The modification of workload level should be dealt with event mechanism")

    def _exec_commands_before_sql(self, db_controller: BaseDBController):
        if self._can_trigger():
            if self.drop_other:
                db_controller.drop_all_indexes()
            for index in self.indexes:
                db_controller.create_index(index)
            self.have_been_triggered = True

    def _add_trans_params(self, params: dict):
        # the empty function is meaningful for removing all params from superclass.
        pass

    def _roll_back(self, db_controller):
        # self.is_can_trigger() is False if indexes has been built
        if not self._can_trigger():
            for index in self.indexes:
                db_controller.drop_index(index)
