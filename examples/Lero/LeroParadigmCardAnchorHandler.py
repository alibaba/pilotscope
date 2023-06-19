from Anchor.BaseAnchor.replaceAnchorHandler import CardAnchorHandler
from Factory.DBControllerFectory import DBControllerFactory
from PilotConfig import PilotConfig
from DataFetcher.PilotStateManager import PilotStateManager
from PilotModel import PilotModel
from PilotTransData import PilotTransData


class LeroParadigmCardAnchorHandler(CardAnchorHandler):

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.data_fetcher = PilotStateManager(config)

    def predict(self, plans):
        return plans[0]

    def user_custom_task(self, sql):
        # self.data_fetcher.fetch_subquery_card()
        # result: PilotTransData = self.data_fetcher.execute(sql)
        # subquery_2_card = result.subquery_2_card
        #
        # factors = [-10, -1, 1, 10]
        # plans = []
        # for factor in factors:
        #     new_subquery_2_card = self.scale_card(subquery_2_card, factor)
        #     self.data_fetcher.set_card(new_subquery_2_card)
        #     self.data_fetcher.fetch_physical_plan()
        #     result: PilotTransData = self.data_fetcher.execute(sql)
        #     plans.append(result.physical_plan)

        return {"subquery1": 1, "subquery2": 2}


def scale_card(subquery_2_card: dict, factor):
    res = {}
    for key, value in subquery_2_card.items():
        res[key] = value * factor
    return res
