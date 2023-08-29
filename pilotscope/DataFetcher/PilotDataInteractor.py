import threading
import time
import pandas
from concurrent.futures import Future
from concurrent.futures.thread import ThreadPoolExecutor
from typing import Optional, List

from pilotscope.Anchor.BaseAnchor.PullAnchorHandler import *
from pilotscope.Anchor.BaseAnchor.PushAnchorHandler import *
from pilotscope.DataFetcher.BaseDataFetcher import DataFetcher
from pilotscope.DataFetcher.PilotCommentCreator import PilotCommentCreator
from pilotscope.Exception.Exception import DBStatementTimeoutException, HttpReceiveTimeoutException
from pilotscope.Factory.AnchorHandlerFactory import AnchorHandlerFactory
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.DataFetchFactory import DataFetchFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import FetchMethod, ExperimentTimeEnum, DatabaseEnum
from pilotscope.PilotTransData import PilotTransData
from pilotscope.common.Thread import ValueThread
from pilotscope.common.TimeStatistic import TimeStatistic
from pilotscope.common.Util import pilotscope_exit, extract_anchor_handlers, extract_handlers, wait_futures_results


class PilotDataInteractor:
    """The core module for interacting with DBMS and handling push-and-pull operators
    """    
    def __init__(self, config: PilotConfig, db_controller: BaseDBController = None) -> None:
        self.db_controller = DBControllerFactory.get_db_controller(config) if db_controller is None else db_controller
        self.anchor_to_handlers = {}
        self.config = config
        self.port = None
        self.analyzed = False
        self.data_fetcher: DataFetcher = DataFetchFactory.get_data_fetcher(config)

    def execute_batch(self, sqls, is_reset=True) -> List[Optional[PilotTransData]]:
        """Execute sqls sequentially

        :param sqls: list of string, whose items are sqls 
        :type sqls: list
        :param is_reset: If it is True, all anchors will be removed after execution
        :type is_reset: bool, optional
        :return: list of the results
        :rtype: List[Optional[PilotTransData]]
        """        
        datas = []
        flag = False
        for i, sql in enumerate(sqls):
            if i == len(sqls) - 1:
                flag = is_reset
            datas.append(self.execute(sql, is_reset=flag))
        return datas

    def execute_parallel(self, sqls, parallel_num=10, is_reset=True):
        """Execute sqls parallelly

        :param sqls: list of string, whose items are sqls 
        :type sqls: list
        :param parallel_num: the number of threads, defaults to 10
        :type parallel_num: int, optional
        :param is_reset: If it is True, all anchors will be removed after execution
        :type is_reset: bool, optional
        :raises RuntimeError: simulate index does not support execute_parallel
        :return: list of the results
        :rtype: list of Future
        """        
        if self.db_controller.enable_simulate_index:
            raise RuntimeError("simulate index does not support execute_parallel")

        parallel_num = min(len(sqls), parallel_num)
        with ThreadPoolExecutor(max_workers=parallel_num) as pool:
            futures = []
            for sql in sqls:
                future: Future = pool.submit(self.execute, sql, False)
                future.add_done_callback(self._reset_connection)
                futures.append(future)
            results = wait_futures_results(futures)
        if is_reset:
            self.reset()

        return results

    def execute(self, sql, is_reset=True) -> Optional[PilotTransData]:
        """Execute this SQL and finish all registered push-and-pull operators before.

        :param sql: sql statement
        :type sql: str
        :param is_reset: If it is True, all anchors will be removed after execution
        :type is_reset: bool, optional
        :return: If no exceptions, it returns a ``PilotTransData`` representing extended result; otherwise, it returns None. 
        :rtype: Optional[PilotTransData]
        """        
        try:
            TimeStatistic.start("connect_if_loss")
            if not self.db_controller.is_connect():
                self.db_controller.connect_if_loss()
            TimeStatistic.end("connect_if_loss")

            origin_sql = sql
            enable_receive_pilot_data = self.is_need_to_receive_data(self.anchor_to_handlers)

            # create pilot comment
            comment_creator = PilotCommentCreator(enable_receive_pilot_data=enable_receive_pilot_data)
            comment_creator.add_params(self.data_fetcher.get_additional_info())
            comment_creator.enable_terminate(
                False if AnchorEnum.RECORD_PULL_ANCHOR in self.anchor_to_handlers else True)
            comment_creator.add_anchor_params(self._get_anchor_params_as_comment())
            comment_sql = comment_creator.create_comment_sql(sql)

            # execution sqls. Sometimes, data do not need to be got from inner
            is_execute_comment_sql = self.is_execute_comment_sql(self.anchor_to_handlers)

            TimeStatistic.start("_execute_sqls")
            records, python_sql_execution_time = self._execute_sqls(comment_sql, is_execute_comment_sql)
            TimeStatistic.end("_execute_sqls")

            # wait to fetch data
            TimeStatistic.start("is_need_to_receive_data")
            if self.is_need_to_receive_data(self.anchor_to_handlers):
                receive_data = self.data_fetcher.wait_until_get_data()
                data: PilotTransData = PilotTransData.parse_2_instance(receive_data, origin_sql)
                self._add_detailed_time_for_experiment(data)
                # fetch data from outer
            else:
                data = PilotTransData()
            TimeStatistic.end("is_need_to_receive_data")
            if records is not None:
                if self.config.db_type == DatabaseEnum.POSTGRESQL:
                    data.records = pandas.DataFrame.from_records(records[1:],columns=records[0])
                else:
                    data.records = records
            data.sql = origin_sql
            TimeStatistic.start("_fetch_data_from_outer")
            self._fetch_data_from_outer(origin_sql, data)
            TimeStatistic.end("_fetch_data_from_outer")

            if self.config.db_type == DatabaseEnum.SPARK:
                self._add_execution_time_from_python(data, python_sql_execution_time)

            # clear state
            if is_reset:
                self.reset()
            return data

        except (DBStatementTimeoutException, HttpReceiveTimeoutException) as e:
            self._add_detailed_time_for_experiment(None)
            print(e)
            return None
        except Exception as e:
            raise e

    def _add_execution_time_from_python(self, data: PilotTransData, python_sql_execution_time):
        if AnchorEnum.EXECUTION_TIME_PULL_ANCHOR in self.anchor_to_handlers:
            data.execution_time = python_sql_execution_time

    def _add_detailed_time_for_experiment(self, data: PilotTransData):
        if data is not None:
            TimeStatistic.add_time(ExperimentTimeEnum.DB_PARSER, data.parser_time)
                        
            for i in range(len(data.anchor_names)):
                anchor_name = data.anchor_names[i]
                anchor_time = data.anchor_times[i]
                TimeStatistic.add_time(ExperimentTimeEnum.get_anchor_key(anchor_name), float(anchor_time))

            if data.execution_time is not None:
                TimeStatistic.add_time(ExperimentTimeEnum.SQL_TOTAL_TIME, data.execution_time)
        else:
            TimeStatistic.add_time(ExperimentTimeEnum.SQL_TOTAL_TIME, self.config.sql_execution_timeout)

    def is_need_to_receive_data(self, anchor_2_handlers):
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        if AnchorEnum.RECORD_PULL_ANCHOR in filter_anchor_2_handlers:
            filter_anchor_2_handlers.pop(AnchorEnum.RECORD_PULL_ANCHOR)

        # for experiment need, Pilotscope_SparkSQL will send http_time and parser_time via http, so we comment this
        # the execution time is not needed to be received for spark
        # if self.config.db_type == DatabaseEnum.SPARK:
        #     if AnchorEnum.EXECUTION_TIME_PULL_ANCHOR in filter_anchor_2_handlers:
        #         filter_anchor_2_handlers.pop(AnchorEnum.EXECUTION_TIME_PULL_ANCHOR)

        return len(filter_anchor_2_handlers) > 0

    def is_execute_comment_sql(self, anchor_2_handlers):
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        return len(filter_anchor_2_handlers) > 0

    # def _roll_back_db(self):
    #     handlers = extract_handlers(self.anchor_to_handlers.values(), is_fetch_anchor=False)
    #     [handler.roll_back(self.db_controller) for handler in handlers]

    def reset(self):
        # self._roll_back_db()
        self.anchor_to_handlers.clear()
        self._reset_connection()

    def _reset_connection(self, *args, **kwargs):
        # todo
        if self.config.db_type != DatabaseEnum.SPARK:
            self.db_controller.reset()

    def _execute_sqls(self, comment_sql, is_execute_comment_sql):
        handlers = extract_handlers(self.anchor_to_handlers.values(), is_fetch_anchor=False)
        handlers = sorted(handlers, key= lambda x: x.priority)
        TimeStatistic.start("execute_before_comment_sql")
        for handler in handlers:
            handler.execute_before_comment_sql(self.db_controller)
        TimeStatistic.end("execute_before_comment_sql")

        TimeStatistic.start("self.db_controller.execute")
        records = python_sql_execution_time = None
        if is_execute_comment_sql:
            start_time = time.time()
            records = self.db_controller.execute(comment_sql, fetch=True, fetch_column_name=True)
            python_sql_execution_time = time.time() - start_time
        TimeStatistic.end("self.db_controller.execute")
        return records, python_sql_execution_time

    def _get_anchor_params_as_comment(self):
        anchor_params = {}
        for anchor, handle in self.anchor_to_handlers.items():
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
            elif isinstance(handle, PullAnchorHandler) and handle.fetch_method == FetchMethod.INNER:
                handle.add_params_to_db_core(params)
            if len(params) > 0:
                anchor_params[anchor.name] = params
        return anchor_params

    def _remove_outer_fetch_anchor(self, anchor_to_handlers):
        result = {}
        for anchor, handle in anchor_to_handlers.items():
            if isinstance(handle, PullAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                continue
            result[anchor] = handle
        return result

    def _fetch_data_from_outer(self, sql, data: PilotTransData):
        replace_anchor_params = self._get_replace_anchor_params(self.anchor_to_handlers.values())
        anchor_data = AnchorTransData()
        handles = self.anchor_to_handlers.values()
        handles = sorted(handles, key= lambda x: x.priority)
        for handle in handles:
            if isinstance(handle, PullAnchorHandler) and handle.fetch_method == FetchMethod.OUTER:
                comment_creator = PilotCommentCreator(anchor_params=replace_anchor_params, enable_terminate_flag=False)
                comment = comment_creator.create_comment()
                handle.fetch_from_outer(self.db_controller, sql, comment, anchor_data, data)

    def _get_replace_anchor_params(self, handles):
        anchor_params = {}
        for handle in handles:
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
                if len(params) > 0:
                    anchor_params[handle.anchor_name] = params
        return anchor_params

    def add_anchors(self, handlers):
        for handler in handlers:
            self.anchor_to_handlers[AnchorEnum.to_anchor_enum(handler.anchor_name)] = handler

    def add_anchor(self, anchor, handler):
        if isinstance(anchor, str):
            anchor = AnchorEnum.to_anchor_enum(anchor)
        self.anchor_to_handlers[anchor] = handler

    def push_hint(self, key_2_value_for_hint: dict):
        anchor: HintAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.HINT_PUSH_ANCHOR)
        anchor.key_2_value_for_hint = key_2_value_for_hint
        self.anchor_to_handlers[AnchorEnum.HINT_PUSH_ANCHOR] = anchor

    def push_card(self, subquery_2_value: dict):
        anchor: CardAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.CARD_PUSH_ANCHOR)
        anchor.subquery_2_card = subquery_2_value
        self.anchor_to_handlers[AnchorEnum.CARD_PUSH_ANCHOR] = anchor

    def push_knob(self, key_2_value_for_knob: dict):
        anchor: KonbAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.KNOB_PUSH_ANCHOR)
        anchor.key_2_value_for_knob = key_2_value_for_knob
        self.anchor_to_handlers[AnchorEnum.KNOB_PUSH_ANCHOR] = anchor

    def push_cost(self, subplan_2_cost: dict):
        raise NotImplementedError
        anchor: CostAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.COST_PUSH_ANCHOR)
        anchor.subplan_2_cost = subplan_2_cost
        self.anchor_to_handlers[AnchorEnum.COST_PUSH_ANCHOR] = anchor

    def push_rule(self):
        pass

    def push_index(self, indexes: List[Index], drop_other=True):
        anchor: IndexAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                             AnchorEnum.INDEX_PUSH_ANCHOR)
        anchor.indexes = indexes
        anchor.drop_other = drop_other
        self.anchor_to_handlers[AnchorEnum.INDEX_PUSH_ANCHOR] = anchor
        pass

    def pull_hint(self):
        pass

    def pull_subquery_card(self):
        anchor: SubQueryCardPullAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                         AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR] = anchor
        if self.config.db_type == DatabaseEnum.SPARK and not self.analyzed:
            self.db_controller.analyze_all_table_stats()
            self.analyzed = True

    def pull_rewrite_sql(self):
        pass

    def pull_logical_plan(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.LOGICAL_PLAN_PULL_ANCHOR] = anchor

    def pull_physical_plan(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR] = anchor

    def pull_execution_time(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.EXECUTION_TIME_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.EXECUTION_TIME_PULL_ANCHOR] = anchor

    def pull_record(self):
        anchor: RecordPullAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                   AnchorEnum.RECORD_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.RECORD_PULL_ANCHOR] = anchor

    def pull_buffercache(self):
        anchor: BuffercachePullAnchorHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                        AnchorEnum.BUFFERCACHE_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.BUFFERCACHE_PULL_ANCHOR] = anchor

    def pull_real_node_cost(self):
        pass

    def pull_real_node_card(self):
        pass

    def pull_estimated_cost(self):
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.ESTIMATED_COST_PULL_ANCHOR)
        self.anchor_to_handlers[AnchorEnum.ESTIMATED_COST_PULL_ANCHOR] = anchor
