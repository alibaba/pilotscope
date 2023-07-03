from typing import Optional, List

from Anchor.BaseAnchor.FetchAnchorHandler import *
from Anchor.BaseAnchor.replaceAnchorHandler import *
from DataFetcher.BaseDataFetcher import DataFetcher
from DataFetcher.PilotCommentCreator import PilotCommentCreator
from Exception.Exception import DBStatementTimeoutException, HttpReceiveTimeoutException
from Factory.AnchorHandlerFactory import AnchorHandlerFactory
from Factory.DBControllerFectory import DBControllerFactory
from Factory.DataFetchFactory import DataFetchFactory
from PilotConfig import PilotConfig
from PilotEnum import FetchMethod
from PilotTransData import PilotTransData
from common.Util import pilotscope_exit, extract_anchor_handlers, extract_handlers


class PilotStateManager:

    def __init__(self, config: PilotConfig) -> None:
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.anchor_to_handlers = {}
        self.config = config
        self.port = None
        self.data_fetcher: DataFetcher = DataFetchFactory.get_data_fetcher(config)

    def execute_batch(self, sqls, enable_clear=True) -> List[Optional[PilotTransData]]:
        datas = []
        flag = False
        for i, sql in enumerate(sqls):
            if i == len(sqls) - 1:
                flag = enable_clear
            datas.append(self.execute(sql, enable_clear=flag))
        return datas

    def execute(self, sql, enable_clear=True) -> Optional[PilotTransData]:
        try:
            origin_sql = sql
            enable_receive_pilot_data = self.is_need_to_receive_data(self.anchor_to_handlers)
            # create pilot comment
            comment_creator = PilotCommentCreator(enable_receive_pilot_data=enable_receive_pilot_data)
            comment_creator.add_params(self.data_fetcher.get_additional_info())
            comment_creator.enable_terminate(
                False if AnchorEnum.RECORD_FETCH_ANCHOR in self.anchor_to_handlers else True)
            comment_creator.add_anchor_params(self._get_anchor_params_as_comment())
            comment_sql = comment_creator.create_comment_sql(sql)

            # execution sqls. Sometimes, data do not need to be got from inner
            is_execute_comment_sql = self.is_execute_comment_sql(self.anchor_to_handlers)
            records = self._execute_sqls(comment_sql, is_execute_comment_sql)

            # wait to fetch data
            if self.is_need_to_receive_data(self.anchor_to_handlers):
                receive_data = self.data_fetcher.wait_until_get_data()
                data: PilotTransData = PilotTransData.parse_2_instance(receive_data, origin_sql)
                # fetch data from outer
                self._fetch_data_from_outer(origin_sql, data)
            else:
                data = PilotTransData()

            data.records = records
            data.sql = origin_sql
            self._fetch_data_from_outer(origin_sql, data)

            # clear state
            if enable_clear:
                self.clear()
            return data

        except (DBStatementTimeoutException, HttpReceiveTimeoutException) as e:
            print(e)
            return None
        except Exception as e:
            pilotscope_exit()
            raise e

    def is_need_to_receive_data(self, anchor_2_handlers):
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        if AnchorEnum.RECORD_FETCH_ANCHOR in filter_anchor_2_handlers:
            filter_anchor_2_handlers.pop(AnchorEnum.RECORD_FETCH_ANCHOR)
        return len(filter_anchor_2_handlers) > 0

    def is_execute_comment_sql(self, anchor_2_handlers):
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        return len(filter_anchor_2_handlers) > 0

    def _roll_back_db(self):
        handlers = extract_handlers(self.anchor_to_handlers.values(), is_fetch_anchor=False)
        [handler.roll_back(self.db_controller) for handler in handlers]

    def clear(self):
        self._roll_back_db()
        self.anchor_to_handlers.clear()

    def _execute_sqls(self, comment_sql, is_execute_comment_sql):
        handlers = extract_handlers(self.anchor_to_handlers.values(), is_fetch_anchor=False)
        for handler in handlers:
            handler.execute_before_comment_sql(self.db_controller)
        return self.db_controller.execute(comment_sql, fetch=True) if is_execute_comment_sql else None

    def _get_anchor_params_as_comment(self):
        anchor_params = {}
        for anchor, handle in self.anchor_to_handlers.items():
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
            elif isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.INNER:
                handle.add_params_to_db_core(params)
            if len(params) > 0:
                anchor_params[anchor.name] = params
        return anchor_params

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
                handle.fetch_from_outer(self.db_controller, sql, comment, anchor_data, data)

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

    def set_index(self, indexes: List[Index], drop_other=True):
        anchor: IndexAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                             AnchorEnum.INDEX_REPLACE_ANCHOR)
        anchor.indexes = indexes
        anchor.drop_other = drop_other
        self.anchor_to_handlers[AnchorEnum.INDEX_REPLACE_ANCHOR] = anchor
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
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.PHYSICAL_PLAN_FETCH_ANCHOR] = anchor

    def fetch_execution_time(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.EXECUTION_TIME_FETCH_ANCHOR] = anchor

    def fetch_record(self):
        anchor: RecordFetchAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                   AnchorEnum.RECORD_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.RECORD_FETCH_ANCHOR] = anchor
    
    def fetch_buffercache(self):
        anchor: BuffercacheFetchAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                         AnchorEnum.BUFFERCACHE_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.BUFFERCACHE_FETCH_ANCHOR] = anchor

    def fetch_real_node_cost(self):
        pass

    def fetch_real_node_card(self):
        pass

    def fetch_estimated_cost(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.ESTIMATED_COST_FETCH_ANCHOR] = anchor
