import os


class PilotSysConfig:
    # database
    DATA_COLLECT_TABLE_PRIMARY_ID = "pilot_data_id"
    USER_DATA_DB_NAME = "PilotScopeUserData"
    COLLECT_DATA_VISIT_RECORD_TABLE = "collect_data_visit"

    # Anchor
    ANCHOR_TRANS_JSON_KEY = "anchor"

    # data
    DATA_BASE = "../cacheData/"
    PILOT_MODEL_DATA_BASE = os.path.join(DATA_BASE, "pilotModel")
