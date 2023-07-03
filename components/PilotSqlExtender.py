from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler
from DBController.BaseDBController import BaseDBController
from DataFetcher.PilotCommentCreator import PilotCommentCreator
from PilotConfig import PilotConfig
from PilotEnum import FetchMethod
from utlis import connect_comment_and_sql


class PilotSqlExtender:

    def __init__(self, db_controller: BaseDBController, config: PilotConfig) -> None:
        self.db_controller: BaseDBController = db_controller
        self.config = config

        self.anchor_to_handlers: dict = {}

    def register_anchors(self, anchor_to_handlers: dict):
        self.anchor_to_handlers.update(anchor_to_handlers)

    def get_extend_sqls(self, sql, comment_creator: PilotCommentCreator):
        sqls = []
        self._add_sqls(sqls)
        anchor_params = self._get_anchor_params_as_comment()
        comment_creator.add_anchor_params(anchor_params)
        comment = comment_creator.create_comment()
        sqls.append(connect_comment_and_sql(comment, sql))
        return comment, sqls

    def _add_sqls(self, sqls):
        for anchor, handle in self.anchor_to_handlers.items():
            if isinstance(handle, ReplaceAnchorHandler):
                sqls.extend(handle.execute_before_comment_sql(None))

    def _get_anchor_params_as_comment(self):
        anchor_params = {}
        for anchor, handle in self.anchor_to_handlers.items():
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
            elif isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.INNER:
                handle.add_params_to_db_core(params)
            if len(params) > 0 :
                anchor_params[anchor.name] = params
        return anchor_params
