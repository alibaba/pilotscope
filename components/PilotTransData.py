import json


class PilotTransData:

    def __init__(self) -> None:
        self.sql: str = None
        self.records = None
        self.anchor_name = None
        self.physical_plan = None
        self.logical_plan = None
        self.execution_time = None
        self.subquery_2_card: dict = {}

    @classmethod
    def parse_2_instance(cls, target_json: str):
        target_json = json.loads(target_json)
        data = PilotTransData()
        for key, value in target_json.items():
            if key in data.__dict__:
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
            data.subquery_2_card[subquery[i]] = int(cards[i])

    def add_property(self, key, value):
        self.__dict__[key] = value
