import time
from concurrent.futures import Future
from concurrent.futures.thread import ThreadPoolExecutor
from typing import Optional, List, cast

import pandas

from pilotscope.Anchor.BaseAnchor.BasePullHandler import *
from pilotscope.Anchor.BaseAnchor.BasePushHandler import *
from pilotscope.Common.Util import extract_anchor_handlers, extract_handlers, wait_futures_results
from pilotscope.DBInteractor.InteractorReceiver import InteractorReceiver
from pilotscope.DBInteractor.PilotCommentCreator import PilotCommentCreator
from pilotscope.Exception.Exception import DBStatementTimeoutException, InteractorReceiveTimeoutException
from pilotscope.Factory.AnchorHandlerFactory import AnchorHandlerFactory
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.Factory.InteractorReceiverFactory import InteractorReceiverFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotEnum import FetchMethod, DatabaseEnum
from pilotscope.PilotTransData import PilotTransData


# noinspection PyProtectedMember
class PilotDataInteractor:
    """The core module for interacting with DBMS and handling push-and-pull operators
    """

    def __init__(self, config: PilotConfig, enable_simulate_index=False) -> None:
        """

        :param config: The configuration of PilotScope.
        :param enable_simulate_index: A flag indicating whether to enable the simulated index. This flag is only valid for PostgreSQL.
        """
        self.db_controller = DBControllerFactory.get_db_controller(config, enable_simulate_index=enable_simulate_index)
        self._anchor_to_handlers = {}
        self.config = config
        self.spark_analyzed = False
        self._data_fetcher: InteractorReceiver = InteractorReceiverFactory.get_data_fetcher(config)

    def push_hint(self, key_2_value_for_hint: dict):
        """
        Set the value of each hint (i.e., the run-time config) when execute SQL queries.
        The hints can be used to control the behavior of the database system in a session.

        For PostgreSQL, you can find all valid hints in https://www.postgresql.org/docs/13/runtime-config.html.

        For Spark, you can find all valid hints (called conf in Spark) in https://spark.apache.org/docs/latest/configuration.html#runtime-sql-configuration

        Note that you need to distinguish which parameter is static (push_knob) and which is run-time (push_hint).

        :param key_2_value_for_hint: A dictionary containing key-value pairs representing hint information, e.g.
            {"hint_key": "hint_value"}.
        """
        anchor: HintPushHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.HINT_PUSH_ANCHOR)
        anchor.key_2_value_for_hint = key_2_value_for_hint
        self._anchor_to_handlers[AnchorEnum.HINT_PUSH_ANCHOR] = anchor

    def push_knob(self, key_2_value_for_knob: dict):
        """
        Set the value of each knob parameter (i.e., the static config) of database.
        These parameters are valid after the database is restarted.
        Thus, pilotscope will restart the database if this function is called.

        For PostgreSQL, you can find all valid knob in https://www.postgresql.org/docs/13/runtime-config.html.
        Pilotscope will modify the configuration file (i.e., postgresql.conf) of PostgreSQL to set the knob.

        For Spark, you can find all valid hints (called conf in Spark) in https://spark.apache.org/docs/latest/configuration.html

        Note that you need to distinguish which parameter is static (push_knob) and which is run-time (push_hint).

        :param key_2_value_for_knob: A dictionary containing key-value pairs for knob settings, e.g.
            {"knob_key": "knob_value"}
        """
        anchor: KnobPushHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.KNOB_PUSH_ANCHOR)
        anchor.key_2_value_for_knob = key_2_value_for_knob
        self._anchor_to_handlers[AnchorEnum.KNOB_PUSH_ANCHOR] = anchor

    def push_card(self, subquery_2_value: dict, enable_parameterized_subquery=False):
        """
        Set the cardinality of each sub-plan query when execute a SQL query.
        The cardinality of each sub-plan query will set to the default estimated value if you don't provide the value.

        :param subquery_2_value: A dictionary containing subquery to card value mappings, e.g.
            {"subquery_1": "card_1", "subquery_2": "card_2"}
        :param enable_parameterized_subquery: A flag indicating whether to enable parameterized subquery.

        """
        anchor: CardPushHandler = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.CARD_PUSH_ANCHOR)
        anchor.subquery_2_card = subquery_2_value
        if self.config.db_type == DatabaseEnum.POSTGRESQL:
            anchor.enable_parameterized_subquery = enable_parameterized_subquery
        self._anchor_to_handlers[AnchorEnum.CARD_PUSH_ANCHOR] = anchor

    def push_pg_hint_comment(self, pg_hint_comment: str):
        """
        Set the comment of `pg_hint_plan` into input SQL query. The function is only valid for PostgreSQL.
        The `pg_hint_plan` is an extension for the PostgreSQL database that allows users to influence the query planner's choice of execution plans.
        You can find more information in https://github.com/ossc-db/pg_hint_plan.

        :param pg_hint_comment: a pg_hint_comment like ``/*+ HashJoin(a b) SeqScan(a) */``, which indicate the join method of `a` and `b` is HashJoin and the scan method of `a` is SeqScan.
        """

        if self.config.db_type != DatabaseEnum.POSTGRESQL:
            raise NotImplementedError("PG Hint only is implemented for PostgresSQL database")
        anchor: CommentPushHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                             AnchorEnum.COMMENT_PUSH_ANCHOR)
        anchor.comment_str = pg_hint_comment
        self._anchor_to_handlers[AnchorEnum.COMMENT_PUSH_ANCHOR] = anchor

    def _push_subplan_cost(self, subplan_2_cost: dict):
        """
        Assigns cost information to subplans and registers the cost push handler.

        :param subplan_2_cost: A dictionary mapping subplans to their associated costs, e.g.
            {"subplan_1": 100, "subplan_2": 200}
        :raises NotImplementedError: Indicates that the method has not been implemented yet.
        """
        raise NotImplementedError

    def _push_rule(self):
        """
        Placeholder method for pushing rule information.
        """
        raise NotImplementedError

    def push_index(self, indexes: List[Index], drop_other=True):
        """
        Set the index information of each table when execute SQL queries.
        The index will be built before executing all SQL queries in a session of PilotDataInteractor.

        :param indexes: A list of `Index` instances to be handled.
        :param drop_other: A flag indicating whether to drop other indexes not in the `indexes` list.
        """
        anchor: IndexPushHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                           AnchorEnum.INDEX_PUSH_ANCHOR)
        anchor.indexes = indexes
        anchor.drop_other = drop_other
        self._anchor_to_handlers[AnchorEnum.INDEX_PUSH_ANCHOR] = anchor
        pass

    def pull_subquery_card(self, enable_parameterized_subquery=False):
        """
        Require PilotScope to collect all cardinality information of each sub-plan queries when execute a SQL query.

        :param enable_parameterized_subquery: A flag indicating whether to enable parameterized subquery.
        """

        anchor: SubQueryCardPullHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                  AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.SUBQUERY_CARD_PULL_ANCHOR] = anchor
        if self.config.db_type == DatabaseEnum.POSTGRESQL:
            anchor.enable_parameterized_subquery = enable_parameterized_subquery
        if self.config.db_type == DatabaseEnum.SPARK and not self.spark_analyzed:
            self.db_controller.analyze_all_table_stats()
            self.spark_analyzed = True

    def _pull_rewrite_sql(self):
        """
        Placeholder method for pulling SQL rewrite information.
        """
        raise NotImplementedError

    def pull_physical_plan(self):
        """
        Require PilotScope to collect physical plan when execute a SQL query.
        """
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR] = anchor

    def pull_execution_time(self):
        """
        Require PilotScope to collect execution time when execute a SQL query.
        """
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.EXECUTION_TIME_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.EXECUTION_TIME_PULL_ANCHOR] = anchor

    def pull_estimated_cost(self):
        """
        Require PilotScope to collect estimated cost from database's optimizer when execute a SQL query.
        """
        anchor = AnchorHandlerFactory.get_anchor_handler(self.config, AnchorEnum.ESTIMATED_COST_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.ESTIMATED_COST_PULL_ANCHOR] = anchor

    def pull_record(self):
        """
        Require PilotScope to collect execution records when execute a SQL query.
        PilotScode will not to execute a complete process of recode retrieval, unless you require it to collect records.
        """
        anchor: RecordPullHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                            AnchorEnum.RECORD_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.RECORD_PULL_ANCHOR] = anchor

    def pull_buffercache(self):
        """
        Retrieves the buffer cache, where each item include a table name and the numbers of its buffer.
        """
        anchor: BuffercachePullHandler = AnchorHandlerFactory.get_anchor_handler(self.config,
                                                                                 AnchorEnum.BUFFERCACHE_PULL_ANCHOR)
        self._anchor_to_handlers[AnchorEnum.BUFFERCACHE_PULL_ANCHOR] = anchor

    def _pull_real_node_cost(self):
        """
        Placeholder method for pulling real node cost information.
        """
        pass

    def _pull_real_node_card(self):
        """
        Placeholder method for pulling real node cardinality information.
        """
        pass

    def execute_batch(self, sqls, is_reset=True) -> List[Optional[PilotTransData]]:
        """
        Execute all sqls sequentially in a session. All SQL queries is executed using the identical push/pull configuration.

        :param sqls: a list of sqls to be executed
        :param is_reset: If it is true, all `push`/`pull` will be removed after execution
        :return: list of the results for each sql
        """
        datas = []
        flag = False
        for i, sql in enumerate(sqls):
            if i == len(sqls) - 1:
                flag = is_reset
            datas.append(self.execute(sql, is_reset=flag))
        return datas

    def execute_parallel(self, sqls, parallel_num=10, is_reset=True):
        """
        Execute all sqls parallel in a session.
        All SQL queries is executed using the identical push/pull configuration.

        :param sqls: a list of sqls to be executed
        :param parallel_num: the number of threads, defaults to 10
        :param is_reset: If it is true, all `push`/`pull` will be removed after execution
        :raises RuntimeError: simulate index does not support execute_parallel
        :return: list of the results for each sql
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
        """
        Execute this SQL and finish all registered push-and-pull operators before.

        :param sql: a sql statement to be executed
        :param is_reset: If it is true, all `push`/`pull` will be removed after execution
        :return: If no exceptions, it returns a `PilotTransData` representing extended result; otherwise, it returns None.
        """
        try:
            origin_sql = sql
            enable_receive_pilot_data = self._is_need_to_receive_data(self._anchor_to_handlers)

            # create pilot comment
            comment_creator = PilotCommentCreator(enable_receive_pilot_data=enable_receive_pilot_data,
                                                  extra_comment=self._anchor_to_handlers[
                                                      AnchorEnum.COMMENT_PUSH_ANCHOR].comment_str if AnchorEnum.COMMENT_PUSH_ANCHOR in self._anchor_to_handlers else None)
            comment_creator.add_params(self._data_fetcher.get_extra_infos_for_trans())
            comment_creator.enable_terminate(
                False if AnchorEnum.RECORD_PULL_ANCHOR in self._anchor_to_handlers else True)
            comment_creator.add_anchor_params(self._get_anchor_params_as_comment())
            comment_sql = comment_creator.create_comment_sql(sql)

            # execution sqls. Sometimes, data do not need to be got from inner
            is_execute_comment_sql = self._is_execute_comment_sql(self._anchor_to_handlers)

            records, execution_time_from_outer = self._execute_sqls(comment_sql, is_execute_comment_sql)

            # wait to fetch data
            if self._is_need_to_receive_data(self._anchor_to_handlers):
                receive_data = self._data_fetcher.block_for_data_from_db()
                data: PilotTransData = PilotTransData._parse_2_instance(receive_data, origin_sql)
                # fetch data from outer
            else:
                data = PilotTransData()
            if records is not None:
                if self.config.db_type == DatabaseEnum.POSTGRESQL:
                    data.records = pandas.DataFrame.from_records(records[1:], columns=records[0])
                else:
                    data.records = records
            data.sql = origin_sql
            self._fetch_data_from_outer(origin_sql, data)

            if self.config.db_type == DatabaseEnum.SPARK:
                self._add_execution_time(data, execution_time_from_outer)

            # clear state
            if is_reset:
                self.reset()
            return data

        except (DBStatementTimeoutException, InteractorReceiveTimeoutException) as e:
            print(e)
            return None
        except Exception as e:
            raise e

    def reset(self):
        """
        Resets the internal state of the object.
        This method clears all registered push and pull operators, and database connection.
        """
        self._anchor_to_handlers.clear()
        self._reset_connection()

    def _get_all_handlers(self):
        """
        Retrieves all handler objects.

        :return: A list of handler objects.
        :rtype: list
        """
        return self._anchor_to_handlers.values()

    def _add_execution_time(self, data: PilotTransData, execution_time):
        if AnchorEnum.EXECUTION_TIME_PULL_ANCHOR in self._anchor_to_handlers:
            data.execution_time = execution_time

    def _is_need_to_receive_data(self, anchor_2_handlers):
        """
        Determines if data needs to be received based on the presence of anchors.

        :param anchor_2_handlers: A dictionary mapping anchors to their handlers, e.g. {RECORD_PULL_ANCHOR: handler}
        :type anchor_2_handlers: dict

        :return: True if there are remaining anchors that require data to be received, otherwise False.
        :rtype: bool
        """
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        if AnchorEnum.RECORD_PULL_ANCHOR in filter_anchor_2_handlers:
            filter_anchor_2_handlers.pop(AnchorEnum.RECORD_PULL_ANCHOR)
        if self.config.db_type == DatabaseEnum.SPARK and AnchorEnum.EXECUTION_TIME_PULL_ANCHOR in filter_anchor_2_handlers:
            filter_anchor_2_handlers.pop(AnchorEnum.EXECUTION_TIME_PULL_ANCHOR)
        return len(filter_anchor_2_handlers) > 0

    def _is_execute_comment_sql(self, anchor_2_handlers):
        """
        Checks if there is a need to execute comment SQL based on filtered anchors.

        :param anchor_2_handlers: A dictionary containing the mapping of anchors to their handlers, e.g. {RECORD_PULL_ANCHOR: handler}
        :type anchor_2_handlers: dict

        :return: Returns True if there are any anchors left after filtering, indicating a need to 
                execute comment SQL, otherwise False.
        :rtype: bool
        """
        filter_anchor_2_handlers = self._remove_outer_fetch_anchor(
            extract_anchor_handlers(anchor_2_handlers, is_fetch_anchor=True))
        return len(filter_anchor_2_handlers) > 0

    def _reset_connection(self, *args, **kwargs):
        # todo
        if self.config.db_type != DatabaseEnum.SPARK:
            self.db_controller._reset()

    def _execute_sqls(self, comment_sql, is_execute_comment_sql):
        handlers = extract_handlers(self._anchor_to_handlers.values(), extract_pull_anchor=False)
        handlers = sorted(handlers, key=lambda x: cast(BaseAnchorHandler, x).get_call_priority())
        for handler in handlers:
            handler._exec_commands_before_sql(self.db_controller)

        records = execution_time_from_outer = None
        if is_execute_comment_sql:
            start_time = time.time()
            records = self.db_controller.execute(comment_sql, fetch=True, fetch_column_name=True)
            execution_time_from_outer = time.time() - start_time
        return records, execution_time_from_outer

    def _get_anchor_params_as_comment(self):
        anchor_params = {}
        for anchor, handle in self._anchor_to_handlers.items():
            params = {}
            if isinstance(handle, BasePushHandler):
                handle._add_trans_params(params)
            elif isinstance(handle, BasePullHandler) and handle.fetch_method == FetchMethod.INNER:
                handle._add_trans_params(params)
            if len(params) > 0:
                anchor_params[anchor.name] = params
        return anchor_params

    def _remove_outer_fetch_anchor(self, anchor_to_handlers):
        result = {}
        for anchor, handle in anchor_to_handlers.items():
            if isinstance(handle, BasePullHandler) and handle.fetch_method == FetchMethod.OUTER:
                continue
            result[anchor] = handle
        return result

    def _fetch_data_from_outer(self, sql, data: PilotTransData):
        replace_anchor_params = self._get_replace_anchor_params(self._anchor_to_handlers.values())
        anchor_data = AnchorTransData()
        handles = self._anchor_to_handlers.values()
        handles = sorted(handles, key=lambda x: cast(BaseAnchorHandler, x).get_call_priority())
        for handle in handles:
            if isinstance(handle, BasePullHandler) and handle.fetch_method == FetchMethod.OUTER:
                comment_creator = PilotCommentCreator(anchor_params=replace_anchor_params, enable_terminate_flag=False,
                                                      extra_comment=self._anchor_to_handlers[
                                                          AnchorEnum.COMMENT_PUSH_ANCHOR].comment_str if AnchorEnum.COMMENT_PUSH_ANCHOR in self._anchor_to_handlers else None)
                comment = comment_creator.create_comment()
                handle.fetch_from_outer(self.db_controller, sql, comment, anchor_data, data)

    def _get_replace_anchor_params(self, handles):
        anchor_params = {}
        for handle in handles:
            params = {}
            if isinstance(handle, BasePushHandler):
                handle._add_trans_params(params)
                if len(params) > 0:
                    anchor_params[handle.anchor_name] = params
        return anchor_params

    def _add_anchors(self, handlers):
        """
        Adds multiple anchor-handler associations.
        Iterates over a list of handler objects and registers each of them to 
        its corresponding anchor name within the anchor_to_handlers dictionary.

        :param handlers: A list of handler objects, each with an `anchor_name` attribute.
        :type handlers: list
        """
        for handler in handlers:
            self._add_anchor(handler.anchor_name, handler)

    def _add_anchor(self, anchor, handler):
        """
        Registers a handler to a specific anchor.
        If the provided anchor is a string, it converts the string to the corresponding
        `AnchorEnum` member before registering. The method then associates the handler
        with the anchor in the anchor_to_handlers dictionary.

        :param anchor: The anchor identifier, which can be a string or an AnchorEnum member.
        :type anchor: str or AnchorEnum
        :param handler: The handler object to be associated with the anchor.
        :type handler: RecordPullHandler
        """
        if isinstance(anchor, str):
            anchor = AnchorEnum.to_anchor_enum(anchor)
        self._anchor_to_handlers[anchor] = handler
