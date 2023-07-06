from abc import ABC

from Anchor.AnchorEnum import AnchorEnum


class BaseAnchorHandler(ABC):

    def __init__(self, config) -> None:
        self.enable = True
        self.anchor_name = AnchorEnum.BASE_ANCHOR.name
        self.config = config

    def add_params_to_db_core(self, params: dict):
        return params.update({"enable": self.enable, "name": self.anchor_name})
