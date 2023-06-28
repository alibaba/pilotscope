import threading
from typing import Optional

from Anchor.BaseAnchor.FetchAnchorHandler import *
from Anchor.BaseAnchor.replaceAnchorHandler import *
from DataFetcher.BaseDataFetcher import DataFetcher
from DataFetcher.PilotCommentCreator import PilotCommentCreator
from Exception.Exception import DBStatementTimeoutException
from Factory.AnchorHandlerFactory import AnchorHandlerFactory
from Factory.DBControllerFectory import DBControllerFactory
from Factory.DataFetchFactory import DataFetchFactory
from PilotConfig import PilotConfig
from PilotEnum import FetchMethod
from PilotSqlExtender import PilotSqlExtender
from PilotTransData import PilotTransData
from common.Util import pilotscope_exit


class PilotStateManager:

    def __init__(self, config: PilotConfig) -> None:
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.anchor_to_handlers = {}
        self.config = config
        self.port = None
        self.data_fetcher: DataFetcher = DataFetchFactory.get_data_fetcher(config)

    def execute(self, sql, enable_clear=True) -> Optional[PilotTransData]:
        try:
            origin_sql = sql

            # set comments
            comment_creator = PilotCommentCreator()
            enable_terminate = False if AnchorEnum.RECORD_FETCH_ANCHOR in self.anchor_to_handlers else True
            comment_creator.add_params(self.data_fetcher.get_additional_info())
            comment_creator.enable_terminate(enable_terminate)

            sql_extender = PilotSqlExtender(self.db_controller, self.config)
            sql_extender.register_anchors(self._remove_outer_fetch_anchor(self.anchor_to_handlers))

            # sqls contain multiple "set" sql and one query sql (at last).
            _, sqls = sql_extender.get_extend_sqls(sql, comment_creator)
            # print(sqls[-1])
            # execution sqls
            records = self._execute_sqls(sqls)
            # wait to fetch data
            receive_data = self.data_fetcher.wait_until_get_data()

            if receive_data is not None:
                data: PilotTransData = PilotTransData.parse_2_instance(receive_data, origin_sql)
                # fetch data from outer
                self._fetch_data_from_outer(origin_sql, data)
            else:
                data = PilotTransData()
            data.records = records

            # clear state
            if enable_clear:
                self.clear()
            return data
        except DBStatementTimeoutException as e:
            print(e)
            return None
        except Exception as e:
            pilotscope_exit()
            raise e

    def clear(self):
        self.anchor_to_handlers.clear()

    def _execute_sqls(self, sqls):
        records = None
        for sql in sqls:
            # print("execute sql is {}".format(sql))
            records = self.db_controller.execute(sql, fetch=True)
        return records

    def _remove_outer_fetch_anchor(self, anchor_to_handlers):
        result = {}
        for anchor, handle in anchor_to_handlers.items():
            if isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                continue
            result[anchor] = handle
        return result

    def _fetch_data_from_outer(self, sql, data: PilotTransData):
        replace_anchor_params = self._get_replace_anchor_params(self.anchor_to_handlers.values())
        anchor_data = AnchorTransData()
        handles = self.anchor_to_handlers.values()
        for handle in handles:
            if isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                comment_creator = PilotCommentCreator(anchor_params=replace_anchor_params, enable_terminate_flag=False)
                comment = comment_creator.create_comment()
                handle.fetch_from_outer(sql, comment, anchor_data, data)

    def _get_replace_anchor_params(self, handles):
        anchor_params = {}
        for handle in handles:
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
                anchor_params[handle.anchor_name] = params
        return anchor_params

    def add_anchors(self, handlers):
        for handler in handlers:
            self.anchor_to_handlers[AnchorEnum.to_anchor_enum(handler.anchor_name)] = handler

    def add_anchor(self, anchor, handler):
        if isinstance(anchor, str):
            anchor = AnchorEnum.to_anchor_enum(anchor)
        self.anchor_to_handlers[anchor] = handler

    def set_hint(self, key_2_value_for_hint: dict):
        anchor: HintAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.HINT_REPLACE_ANCHOR)
        anchor.key_2_value_for_hint = key_2_value_for_hint
        self.anchor_to_handlers[AnchorEnum.HINT_REPLACE_ANCHOR] = anchor

    def set_card(self, subquery_2_value: dict):
        anchor: CardAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.CARD_REPLACE_ANCHOR)
        anchor.subquery_2_card = subquery_2_value
        self.anchor_to_handlers[AnchorEnum.CARD_REPLACE_ANCHOR] = anchor

    def set_cost(self, subplan_2_cost: dict):
        anchor: CostAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.COST_REPLACE_ANCHOR)
        anchor.subplan_2_cost = subplan_2_cost
        self.anchor_to_handlers[AnchorEnum.COST_REPLACE_ANCHOR] = anchor

    def set_rule(self):
        pass

    def fetch_hint(self):
        pass

    def fetch_subquery_card(self):
        anchor: SubQueryCardFetchAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                         AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.SUBQUERY_CARD_FETCH_ANCHOR] = anchor

    def fetch_rewrite_sql(self):
        pass

    def fetch_logical_plan(self):
        pass

    def fetch_physical_plan(self):
        anchor: PhysicalPlanFetchAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                         AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR] = anchor

    def fetch_execution_time(self):
        anchor: ExecutionTimeFetchAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                          AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR] = anchor

    def fetch_real_node_cost(self):
        pass

    def fetch_real_node_card(self):
        pass
