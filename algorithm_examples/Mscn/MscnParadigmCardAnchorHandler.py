from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData


class MscnCardPushHandler(CardPushHandler):

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.mscn_model = model
        self.config = config
        self.data_interactor = PilotDataInteractor(config)

    def acquire_injected_data(self, sql):
        self.data_interactor.pull_subquery_card()
        data: PilotTransData = self.data_interactor.execute(sql)
        assert data.subquery_2_card is not None
        subquery_2_card = data.subquery_2_card
        subquery = subquery_2_card.keys()
        try:
            _, preds_unnorm, t_total = self.mscn_model.model.predict(subquery)
            # print(subquery, preds_unnorm) Mscn can only handler card that is larger than 0, so we add 1 to all
            # cards in training. In prediction we minus it by 1.
            new_subquery_2_card = {sq: str(max(0.0, pred - 1)) for sq, pred in zip(subquery, preds_unnorm)}
            print("MSCN estimates OK")
        except Exception as e:
            # raise e
            print(e)
            new_subquery_2_card = subquery_2_card
        return new_subquery_2_card
