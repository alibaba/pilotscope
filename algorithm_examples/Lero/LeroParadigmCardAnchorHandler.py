from pilotscope.Anchor.BaseAnchor.BasePushHandler import CardPushHandler
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig
from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotTransData import PilotTransData
from algorithm_examples.Lero.source.model import LeroModelPairWise
from algorithm_examples.Lero.LeroPilotAdapter import CardsPickerModel
import numpy as np

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
        x, _ = feature_generator.transform(plans)
        scores = leroModel.predict(x)
        best_idx = np.argmin(scores)
        return best_idx

    def acquire_injected_data(self, sql):
        
        # Pull subquery and its cardinality
        self.pilot_data_interactor.pull_subquery_card()
        data: PilotTransData = self.pilot_data_interactor.execute(sql)
        assert data is not None
        subquery_2_card = data.subquery_2_card
        
        # Initialize CardsPickerModel and other variables
        cards_picker = CardsPickerModel(subquery_2_card.keys(), subquery_2_card.values())
        scale_subquery_2_card = subquery_2_card
        new_cardss = []
        plans = []
        finish = False
        
        # Core
        while(not finish):
            new_cardss.append(scale_subquery_2_card)
            self.pilot_data_interactor.push_card(scale_subquery_2_card)
            self.pilot_data_interactor.pull_physical_plan()
            data: PilotTransData = self.pilot_data_interactor.execute(sql)
            if data is None:
                continue
            plan = data.physical_plan
            cards_picker.replace(plan)   
            plans.append(plan)
            finish, new_cards = cards_picker.get_cards()
            scale_subquery_2_card = {sq : new_card for sq, new_card in zip(subquery_2_card.keys(), new_cards)}
        best_idx = self.predict(plans)
        selected_card = new_cardss[best_idx]
        print(f"The best plan is {best_idx}/{len(new_cardss)}")
        
        # Return the selected cardinality
        return selected_card
