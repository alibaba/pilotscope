import json

from Anchor.AnchorEnum import AnchorEnum
from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler
from DBController.BaseDBController import BaseDBController
from PilotConfig import PilotConfig
from PilotEnum import FetchMethod
from PilotSysConfig import PilotSysConfig
from utlis import connect_pilot_comment_sql


class PilotSqlExtender:

    def __init__(self, db_controller: BaseDBController, config: PilotConfig) -> None:
        self.db_controller: BaseDBController = db_controller
        self.config = config

        self.anchor_to_handlers: dict = {}
        self.anchor_json_key = PilotSysConfig.ANCHOR_TRANS_JSON_KEY

        self.params = {self.anchor_json_key: {}}

    def register_params(self, key_2_value: dict):
        self.params.update(key_2_value)

    def register_anchors(self, anchor_to_handlers: dict):
        self.anchor_to_handlers.update(anchor_to_handlers)

    def get_extend_sqls(self, sql):
        sqls = []
        self._add_sqls(sqls)
        anchor_params = self._get_anchor_params_as_comment()
        self.params[self.anchor_json_key] = anchor_params

        json_str = json.dumps(self.params)

        if AnchorEnum.RECORD_FETCH_ANCHOR not in self.anchor_to_handlers:
            sql = "explain {}".format(sql)

        comment = "/*{}*/".format(json_str)
        sqls.append(connect_pilot_comment_sql(comment, sql))
        return comment, sqls

    def _add_sqls(self, sqls):
        for anchor, handle in self.anchor_to_handlers.items():
            if isinstance(handle, ReplaceAnchorHandler):
                sqls += handle.get_additional_sqls()

    def _get_anchor_params_as_comment(self):
        anchor_params = {}
        for anchor, handle in self.anchor_to_handlers.items():
            params = {}
            if isinstance(handle, ReplaceAnchorHandler):
                handle.add_params_to_db_core(params)
            elif isinstance(handle, FetchAnchorHandler) and handle.fetch_method == FetchMethod.INNER:
                handle.add_params_to_db_core(params)
            anchor_params[anchor.name] = params
        return anchor_params
