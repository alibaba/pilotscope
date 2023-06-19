# Postgresql conf (Please configure it according to your situation)
PORT = 54321
HOST = "localhost"
USER = "postgres"
PASSWORD = "postgres"
DB = "tpch"
CONNECTION_STR = "dbname=" + DB + " user=" + USER + " password=" + PASSWORD + " host=localhost port=" + str(PORT)
TIMEOUT = 30000000
# [important]
# the data directory of your Postgres in which the database data will live 
# you can execute "show data_directory" in psql to get it
# Please ensure this path is correct, 
# because the program needs to write cardinality files to it 
# to make the optimizer generate some specific execution plans of each query.
PG_DB_PATH = "../../data"

# Rap conf (No modification is required by default)
LERO_SERVER_PORT = 14567
LERO_SERVER_HOST = "localhost"
LERO_SERVER_PATH = "../"
LERO_DUMP_CARD_FILE = "dump_card_with_score.txt"

# Test conf (No modification is required by default)
LOG_PATH = "./log/query_latency"
SEP = "#####"