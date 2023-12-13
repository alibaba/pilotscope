from abc import ABC

from pilotscope.Anchor.AnchorEnum import AnchorEnum


class BaseAnchorHandler(ABC):
    name_2_priority = {
        AnchorEnum.KNOB_PUSH_ANCHOR.name: -1,
        AnchorEnum.EXECUTION_TIME_PULL_ANCHOR.name: 0,
        AnchorEnum.PHYSICAL_PLAN_PULL_ANCHOR.name: 1,
        "OTHER": 9
    }

    def __init__(self, config) -> None:
        self.enable = True
        self.anchor_name = AnchorEnum.BASE_ANCHOR.name
        self.config = config

    def _add_trans_params(self, params: dict):
        return params.update({"enable": self.enable, "name": self.anchor_name})

    def get_call_priority(self):
        if self.anchor_name in self.name_2_priority:
            return self.name_2_priority[self.anchor_name]
        else:
            return self.name_2_priority["OTHER"]
