import json

from pilotscope.Common.Util import is_number


class PilotTransData:

    def __init__(self) -> None:
        self.sql: str = None
        self.records = None
        self.anchor_name = None
        self.physical_plan = None
        self.execution_time = None
        self.estimated_cost = None
        self.buffercache = None
        self.subquery_2_card: dict = {}

    def __str__(self) -> str:
        return "\n".join([str(k) + ": " + str(v) for k, v in self.__dict__.items()])

    @classmethod
    def _parse_2_instance(cls, target_json: str, sql):
        if target_json is str:
            target_json = json.loads(target_json)
        data = PilotTransData()
        data.sql = sql
        for key, value in target_json.items():
            if key in data.__dict__:
                if is_number(value):
                    value = float(value)
                setattr(data, key, value)
        cls._fill_subquery_2_card(data, target_json)
        return data

    @classmethod
    def _fill_subquery_2_card(cls, data, target_json):
        if "card" not in target_json or "subquery" not in target_json:
            return

        cards = target_json["card"]
        subquery = target_json["subquery"]
        assert len(cards) == len(subquery)

        for i in range(0, len(cards)):
            data.subquery_2_card[subquery[i]] = float(cards[i])
