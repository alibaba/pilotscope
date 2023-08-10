from pilotscope.Anchor.BaseAnchor.PushAnchorHandler import CardAnchorHandler
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData


class MscnParadigmCardAnchorHandler(CardAnchorHandler):

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.pilot_data_interactor = PilotDataInteractor(config)

    def user_custom_task(self, sql):
        self.pilot_data_interactor.pull_subquery_card()
        data: PilotTransData = self.pilot_data_interactor.execute(sql)
        assert data.subquery_2_card is not None
        subquery_2_card = data.subquery_2_card
        subquery = subquery_2_card.keys()
        try:
            _, preds_unnorm, t_total = self.model.user_model.predict(subquery)
            print(subquery, preds_unnorm)
            res = {sq : str(pred) for sq, pred in zip(subquery, preds_unnorm)}
            print("OK"*10)
        except Exception as e:
            raise e
            print(e)
            import time
            time.sleep(1)
            res = subquery_2_card
        return res

