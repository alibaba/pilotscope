from Anchor.BaseAnchor.FetchAnchorHandler import *
from Anchor.BaseAnchor.replaceAnchorHandler import *
from DataFetcher.BaseDataFetcher import DataFetcher
from Factory.AnchorHandlerFactory import AnchorHandlerFactory
from Factory.DataFetchFactory import DataFetchFactory
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from PilotEnum import FetchMethod
from PilotSqlExtender import PilotSqlExtender
from PilotTransData import PilotTransData


class PilotStateManager:

    def __init__(self, config: PilotConfig) -> None:
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.anchor_to_handlers = {}
        self.config = config
        self.port = None
        self.data_fetcher: DataFetcher = DataFetchFactory.get_data_fetcher(config)

    def execute(self, sql) -> PilotTransData:
        origin_sql = sql

        self.data_fetcher.prepare_to_receive_data()

        sql_extender = PilotSqlExtender(self.db_controller, self.config)
        sql_extender.register_anchors(self._remove_outer_fetch_anchor(self.anchor_to_handlers))

        # add params for different data fetcher
        sql_extender.register_params(self.data_fetcher.get_additional_info())

        # sqls contain multiple "set" sql and one query sql (at last).
        comment, sqls = sql_extender.get_extend_sqls(sql)

        # execution sqls
        records = self._execute_sqls(sqls)

        # wait to fetch data by inner method
        receive_data = self.data_fetcher.wait_until_get_result()

        # arrange all data
        if receive_data is not None:
            data: PilotTransData = PilotTransData.parse_2_instance(receive_data)
            # fetch data from outer
            self._fetch_data_from_outer(comment, origin_sql, data)
        else:
            data = PilotTransData()
        data.records = records
        return data

    def _execute_sqls(self, sqls):
        records = None
        try:
            for sql in sqls:
                records = self.db_controller.execute(sql, fetch=True)
            return records
        except Exception as e:
            print(e)
        return records

    def _remove_outer_fetch_anchor(self, anchor_to_handlers):
        result = {}
        for anchor, handle in anchor_to_handlers.items():
            if isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                continue
            result[anchor] = handle
        return result

    def _fetch_data_from_outer(self, comment, sql, data: PilotTransData):
        anchor_data = AnchorTransData()
        handles = self.anchor_to_handlers.values()
        for handle in handles:
            if isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                handle.fetch_from_outer(sql, None, anchor_data, data)

    def add_anchors(self, anchor_to_handlers: dict):
        self.anchor_to_handlers.update(anchor_to_handlers)

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
