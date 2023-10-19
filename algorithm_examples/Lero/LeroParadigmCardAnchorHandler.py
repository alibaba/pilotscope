from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData
from algorithm_examples.utils import scale_card
from model import LeroModelPairWise


class LeroCardPushHandler(CardPushHandler):

    def __init__(self, model: PilotModel, config: PilotConfig) -> None:
        super().__init__(config)
        self.model = model
        self.config = config
        self.db_controller = DBControllerFactory.get_db_controller(config)
        self.pilot_data_interactor = PilotDataInteractor(config)

    def predict(self, plans):
        leroModel: LeroModelPairWise = self.model.model
        feature_generator = leroModel._feature_generator
        best_idx = -1
        best_time = float("inf")
        for i, plan in enumerate(plans):
            x, _ = feature_generator.transform([plan])
            time = float(leroModel.predict(x)[0][0])
            if time < best_time:
                best_idx = i
                best_time = time
        return best_idx

    def acquire_injected_data(self, sql):
        factors = [0.1, 1, 10]
        self.pilot_data_interactor.pull_subquery_card()
        data: PilotTransData = self.pilot_data_interactor.execute(sql)
        assert data is not None
        subquery_2_card = data.subquery_2_card

        plans = []
        for f in factors:
            scale_subquery_2_card = scale_card(subquery_2_card, f)
            self.pilot_data_interactor.push_card(scale_subquery_2_card)
            self.pilot_data_interactor.pull_physical_plan()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            if data is None:
                continue
            plans.append(data.physical_plan)

        selected_factor = factors[self.predict(plans)]
        return scale_card(subquery_2_card, selected_factor)
