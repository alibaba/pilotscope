import sys

sys.path.append("../")

from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotModel import PilotModel
from pilotscope.PilotScheduler import PilotScheduler
from algorithm_examples.Mscn.EventImplement import MscnPretrainingModelEvent
from algorithm_examples.Mscn.MscnParadigmCardAnchorHandler import MscnCardPushHandler
from algorithm_examples.Mscn.MscnPilotModel import MscnPilotModel


def get_mscn_preset_scheduler(config, enable_collection, enable_training, num_collection = -1, num_training = -1, num_epoch = 100) -> PilotScheduler:
    if type(enable_collection) == str:
        enable_collection = eval(enable_collection)
    if type(enable_training) == str:
        enable_training = eval(enable_training)
    if type(num_collection) == str:
        num_collection = int(num_collection)
    if type(num_training) == str:
        num_training = int(num_training)
    if type(num_epoch) == str:
        num_epoch = int(num_epoch)

    model_name = "mscn"
    mscn_pilot_model: PilotModel = MscnPilotModel(model_name)
    mscn_pilot_model.load_model()
    mscn_handler = MscnCardPushHandler(mscn_pilot_model, config)

    # core
    test_data_save_table = "{}_data_table".format(model_name)
    pretrain_data_save_table = "{}_pretrain_data_table".format(model_name)
    scheduler: PilotScheduler = SchedulerFactory.create_scheduler(config)
    scheduler.register_custom_handlers([mscn_handler])
    scheduler.register_required_data(test_data_save_table, pull_execution_time=True)
    # allow to pretrain model           
    pretraining_event = MscnPretrainingModelEvent(config, mscn_pilot_model, pretrain_data_save_table,
                                                  enable_collection=enable_collection,
                                                  enable_training=enable_training,
                                                  training_data_file=None, num_collection = num_collection,
                                                  num_training = num_training, num_epoch = num_epoch)
    # If training_data_file is None, training data will be collected in this run
    scheduler.register_events([pretraining_event])

    # start
    scheduler.init()
    return scheduler
