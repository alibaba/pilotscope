import sys

from pilotscope.DataManager.DataManager import DataManager

sys.path.append("../")
sys.path.append("../algorithm_examples/Lero/source")

from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Lero.EventImplement import LeroPretrainingModelEvent, LeroPeriodicCollectEvent, \
    LeroPeriodicModelUpdateEvent
from algorithm_examples.Lero.LeroParadigmCardAnchorHandler import LeroCardPushHandler
from algorithm_examples.Lero.LeroPilotModel import LeroPilotModel


def get_lero_preset_scheduler(config, enable_collection, enable_training) -> PilotScheduler:
    if type(enable_collection) == str:
        enable_collection = eval(enable_collection)
    if type(enable_training) == str:
        enable_training = eval(enable_training)

    model_name = "lero_pair"
    test_data_table = "{}_test_data_table".format(model_name)
    pretraining_data_table = "lero_pretraining_collect_data"

    data_manager = DataManager(config)
    data_manager.remove_table_and_tracker(pretraining_data_table)

    lero_pilot_model: PilotModel = LeroPilotModel(model_name)
    lero_pilot_model.load_model()
    lero_handler = LeroCardPushHandler(lero_pilot_model, config)

    # core
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
    scheduler.register_custom_handlers([lero_handler])
    scheduler.register_required_data(test_data_table, pull_execution_time=True, pull_physical_plan=True)

    # allow to pretrain model
    pretraining_event = LeroPretrainingModelEvent(config, lero_pilot_model, pretraining_data_table,
                                                  enable_collection=enable_collection, enable_training=enable_training)
    scheduler.register_events([pretraining_event])

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

    model_name = "lero_pair"  # This test can only work when existing a model
    lero_pilot_model: PilotModel = LeroPilotModel(model_name)
    lero_pilot_model.load_model()
    lero_handler = LeroCardPushHandler(lero_pilot_model, config)

    # core
    training_data_save_table = "{}_data_table".format(model_name)
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
    scheduler.register_custom_handlers([lero_handler])
    scheduler.register_required_data(training_data_save_table, pull_execution_time=True, pull_physical_plan=True)

    # dynamically collect data
    dynamic_training_data_save_table = "{}_period_training_data_table".format(model_name)
    period_collect_event = LeroPeriodicCollectEvent(dynamic_training_data_save_table, config, 100)
    # dynamically update model
    period_train_event = LeroPeriodicModelUpdateEvent(dynamic_training_data_save_table, config, 100,
                                                      lero_pilot_model)
    scheduler.register_events([period_collect_event, period_train_event])

    # start
    scheduler.init()
    return scheduler
