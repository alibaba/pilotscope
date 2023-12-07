from pilotscope.DBInteractor.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotEnum import DatabaseEnum
from pilotscope.Common.Util import get_pg_hints
from pilotscope.PilotConfig import PilotConfig
import json
# Yuxing Han, Ziniu Wu, Peizhi Wu, Rong Zhu, Jingyi Yang, Liang Wei Tan, Kai Zeng, Gao Cong, Yanzhao Qin, Andreas Pfadler, Zhengping Qian, Jingren Zhou, Jiangneng Li, and Bin Cui. 2021. Cardinality estimation in DBMS: a comprehensive benchmark evaluation. Proc. VLDB Endow. 15, 4 (December 2021), 752–765.
def p_error_calc(config:PilotConfig, sql, estimated_cards:dict, true_cards = None):
    """
    Make sure dict `estimated_cards`' keys are the sub-plan queries of `sql`. 
    `true_cards` is optional. If `true_cards` is None, true card will be calculated in the function, which is more time-consuming.
    """
    data_interactor =  PilotDataInteractor(config)
    if config.db_type == DatabaseEnum.POSTGRESQL:
        if(true_cards is None):
            true_cards = {}
            for k in estimated_cards.keys():
                data_interactor.pull_record()
                res = data_interactor.execute(k)
                true_cards[k] = int(res.records.values[0][0])

        # data_interactor.pull_estimated_cost()
        data_interactor.push_card(true_cards)
        data_interactor.pull_physical_plan() 
        res = data_interactor.execute(sql)
        true_card_plan_hint = get_pg_hints(res.physical_plan)
        
        data_interactor.push_pg_hint_comment(true_card_plan_hint)
        data_interactor.push_card(true_cards)
        data_interactor.pull_estimated_cost()
        data_interactor.pull_physical_plan() # 
        res = data_interactor.execute(sql)
        ppc_opt_plan_true_card = res.estimated_cost
        # print(json.dumps(res.physical_plan),res.estimated_cost,"\n"+"*"*100)
        
        # data_interactor.pull_estimated_cost() 
        # data_interactor.pull_subquery_card()
        data_interactor.push_card(estimated_cards)
        data_interactor.pull_physical_plan()
        res = data_interactor.execute(sql)
        est_card_plan_hints = get_pg_hints(res.physical_plan)
        # print(json.dumps(res.physical_plan),res.estimated_cost,"\n"+"-"*100) #
        # print(res.subquery_2_card)
        
        data_interactor.push_pg_hint_comment(est_card_plan_hints)
        data_interactor.push_card(true_cards)
        data_interactor.pull_estimated_cost()
        data_interactor.pull_physical_plan() # 
        res = data_interactor.execute(sql)
        # print(json.dumps(res.physical_plan),res.estimated_cost) #
        ppc_est_plan_true_card = res.estimated_cost
        
        return ppc_est_plan_true_card/ppc_opt_plan_true_card
    
    else:
        raise NotImplementedError

def q_error_calc(estimated_card,true_card):
    assert(true_card != 0.0 and estimated_card != 0.0)
    return max(true_card/estimated_card, estimated_card/true_card)