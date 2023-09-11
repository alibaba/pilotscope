import sys
sys.path.append("../")
sys.path.append("../examples/Lero/source")

from pilotscope.DataManager.PilotTrainDataManager import PilotTrainDataManager
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.common.Util import pilotscope_exit
from pilotscope.DataFetcher.PilotDataInteractor import PilotDataInteractor
from pilotscope.PilotConfig import PilotConfig,PostgreSQLConfig
from pilotscope.PilotEnum import DatabaseEnum, EventEnum
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from examples.Lero.EventImplement import LeroPretrainingModelEvent, LeroDynamicCollectEventPeriod, LeroPeriodTrainingEvent
from examples.Lero.LeroParadigmCardAnchorHandler import LeroParadigmCardAnchorHandler
from examples.Lero.LeroPilotModel import LeroPilotModel

def get_lero_preset_scheduler(config, enable_collection, enable_training) -> PilotScheduler:
    if type(enable_collection) == str:
        enable_collection = eval(enable_collection)
    if type(enable_training) == str:
        enable_training = eval(enable_training)
    
    model_name = "lero_pair"    
    test_data_table = "{}_test_data_table".format(model_name)
    pretraining_data_table = "lero_pretraining_collect_data"
        
    lero_pilot_model: PilotModel = LeroPilotModel(model_name)
    lero_pilot_model.load()
    lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

    # Register what data needs to be cached for training purposes
    data_interactor = PilotDataInteractor(config)
    data_interactor.pull_physical_plan()
    data_interactor.pull_execution_time()

    # core
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
    scheduler.register_anchor_handler(lero_handler)
    scheduler.register_collect_data(training_data_save_table=test_data_table,
                                    data_interactor=data_interactor)

    # allow to pretrain model
    pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, pretraining_data_table,
                                                    enable_collection=enable_collection, enable_training=enable_training)
    scheduler.register_event(EventEnum.PRETRAINING_EVENT, pretraining_event)

    # start
    scheduler.init()
    return scheduler

def get_lero_dynamic_preset_scheduler(config) -> PilotScheduler:
    
    model_name = "lero_pair"
        
    import torch
    print(torch.version.cuda)
    if torch.cuda.is_available():
        print("Using GPU")
    else:
        print("Using CPU")

    model_name = "lero_pair" # This test can only work when existing a model
    lero_pilot_model: PilotModel = LeroPilotModel(model_name)
    lero_pilot_model.load()
    lero_handler = LeroParadigmCardAnchorHandler(lero_pilot_model, config)

    # Register what data needs to be cached for training purposes
    data_interactor = PilotDataInteractor(config)
    data_interactor.pull_physical_plan()
    data_interactor.pull_execution_time()

    # core
    training_data_save_table = "{}_data_table".format(model_name)
    scheduler: PilotScheduler = SchedulerFactory.get_pilot_scheduler(config)
    scheduler.register_anchor_handler(lero_handler)
    scheduler.register_collect_data(training_data_save_table=training_data_save_table,
                                    data_interactor=data_interactor)

    # dynamically collect data
    dynamic_training_data_save_table = "{}_period_training_data_table".format(model_name)
    period_collect_event = LeroDynamicCollectEventPeriod(dynamic_training_data_save_table, config, 100)
    scheduler.register_event(EventEnum.PERIODIC_COLLECTION_EVENT, period_collect_event)

    # dynamically update model
    period_train_event = LeroPeriodTrainingEvent(dynamic_training_data_save_table, config, 100,
                                                    lero_pilot_model)
    scheduler.register_event(EventEnum.PERIOD_TRAIN_EVENT, period_train_event)

    # start
    scheduler.init()
    return scheduler