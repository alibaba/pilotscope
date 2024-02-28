import sys
sys.path.append("../")
import logging
import readline
from functools import wraps

from algorithm_examples.KnobTuning.SparkKnobPresetScheduler import get_knob_spark_preset_scheduler
from pilotscope.DBController.SparkSQLController import SparkSQLDataSourceEnum
from pilotscope.Factory.SchedulerFactory import SchedulerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig, SparkConfig
from pilotscope.PilotEnum import DatabaseEnum
from algorithm_examples.ExampleConfig import example_pg_bin, example_pgdata

readline.parse_and_bind("tab: complete")
import traceback

from algorithm_examples.Mscn.MscnPresetScheduler import get_mscn_preset_scheduler
from algorithm_examples.Index.IndexPresetScheduler import get_index_preset_scheduler
from algorithm_examples.KnobTuning.KnobPresetScheduler import get_knob_preset_scheduler
from algorithm_examples.Lero.LeroPresetScheduler import get_lero_preset_scheduler, get_lero_dynamic_preset_scheduler

temp_log_file = None
logger = logging.getLogger()
prev_log_level = logger.level


def mute_console_output():
    """
    Redirect stdout and stderr to a temporary file and change the log level to highest.
    """
    global temp_log_file
    global prev_log_level
    prev_log_level = logger.level
    logger.setLevel(51)  # 51 is max than logging.CRITICAL(50)
    temp_log_file = open('temp_log_of_pilotscope_console.txt', 'w')
    sys.stdout = temp_log_file
    sys.stderr = temp_log_file


def recover_console_output():
    """
    Recover change in ``mute_console_output``
    """
    logger.setLevel(prev_log_level)
    sys.stdout = sys.__stdout__
    sys.stderr = sys.__stderr__
    temp_log_file.close()


def mute_console_output_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        recovered = False
        try:
            mute_console_output()
            return func(*args, **kwargs)
        except:
            recover_console_output()
            recovered = True
            traceback.print_exc()
        finally:
            if not recovered:
                recover_console_output()

    return wrapper


def get_postgres_default_scheduler(config):
    assert isinstance(config, PostgreSQLConfig)
    return SchedulerFactory.create_scheduler(config)


def get_spark_default_scheduler(config):
    assert isinstance(config, SparkConfig)
    datasource_type = SparkSQLDataSourceEnum.POSTGRESQL
    datasource_conn_info = {
        'host': 'localhost',
        'db': config.db,
        'user': 'pilotscope',
        'pwd': 'pilotscope'
    }
    config.use_postgresql_datasource(
        db_host=datasource_conn_info["host"],
        db_port=5432,
        db=datasource_conn_info["db"],
        db_user=datasource_conn_info["user"],
        db_user_pwd=datasource_conn_info["pwd"]
    )
    config.set_spark_session_config({
        "spark.sql.pilotscope.enabled": True,
        "spark.sql.cbo.enabled": True,
        "spark.sql.cbo.joinReorder.enabled": True
    })
    return SchedulerFactory.create_scheduler(config)


class PilotConsole:

    def __init__(self) -> None:
        self.config = PostgreSQLConfig()
        self.config.enable_deep_control_local(example_pg_bin, example_pgdata)
        self.taskname2func = {
            "mscn": get_mscn_preset_scheduler,
            "knob_tune": get_knob_preset_scheduler,
            "knob_tune_spark": get_knob_spark_preset_scheduler,
            "index_recom": get_index_preset_scheduler,
            "lero": get_lero_preset_scheduler,
            "lero_dynamic": get_lero_dynamic_preset_scheduler,
            "postgres_default": get_postgres_default_scheduler,
            "spark_default": get_spark_default_scheduler
        }
        self.scheduler = None
        self.echo = False

    def set_database(self, database_name: str):
        if database_name.upper() == DatabaseEnum.POSTGRESQL.name:
            self.config = PostgreSQLConfig()
        elif database_name.upper() == DatabaseEnum.SPARK.name:
            self.config = SparkConfig(app_name="PiloScope", master_url="local[*]")
        else:
            print(f"No database named '{database_name}'. Do nothing")
            return
        print(f"Change database to '{database_name}'")

    def set_config(self, item_name, value):
        """
        set self.config. Before choosing a task, you can set config.
        `item_name` is the name of item in `PostgreSQLConfig` or `SparkConfig`, and `value` are value to set to.
        """
        setattr(self.config, item_name, value)
        # print(self.config.print())
        print(f"set {item_name} to {value} successfully.")

    def use(self, task_name, *args):
        """
        Choose a task. The task name is in self.taskname2func. `args` is the parameters of the function that is the values self.taskname2func.
        For instance, `use mscn False False` will call `self.scheduler = get_mscn_preset_scheduler(config, False, False)`.
        """
        if task_name not in self.taskname2func:
            print(f"No task named '{task_name}'. Do nothing")
        else:
            print(f"Changing task to '{task_name}'")
            if not self.echo:
                func = mute_console_output_decorator(self.taskname2func[task_name])
            else:
                func = self.taskname2func[task_name]
            try:
                self.scheduler = func(self.config, *args)
            except:
                traceback.print_exc()

    def run(self, *args):
        """
        Use `run <sql statement>` to execute a sql, e.g. `run select * from badges limit 10;`.
        It only can be used after choosing a task, i.e. executing `use <task name>` 
        """
        sql = " ".join(args)
        data = None
        if not self.echo:
            func = mute_console_output_decorator(self.scheduler.execute)
        else:
            func = self.scheduler.execute
        try:
            data = func(sql)
        except:
            traceback.print_exc()
        print(data.to_string(index=False))

    def set_echo(self, false_or_true):
        """
        Set self.echo. If self.echo is True, all outputs will print to console. 
        """
        arg = eval(false_or_true)
        self.echo = arg
        print(f"echo set to '{arg}'")

    def console(self):
        """
        Every function in ``PilotConsole`` can be called as a command and the following is the parameters, e.g. `set_config set_db stats_tiny`.
        """
        command_set = set([x for x in dir(self) if not x.startswith("__")])
        while True:
            command = input('> ')
            if command.strip() == "":
                continue
            if command.lower() == "exit":
                break
            else:
                command_list = [x.strip() for x in command.split(" ") if x.strip() != ""]
                if command_list[0] in command_set:
                    try:
                        # print(command_list)
                        getattr(self, command_list[0])(*command_list[1:])
                    except:
                        traceback.print_exc()
                else:
                    print(f"PilotConsole: command type '{command_list[0]}' not exist!")


if __name__ == "__main__":
    """
    use case 1(card-est):

        > set_config set_db stats_tiny # Optional, because of the default of config.db is stats_tiny
        > use mscn True True # Use task mscn
        > run select * from badges limit 10 # Run a query
        
        After running the first time, it could be `use mscn False False` to disable training data collection and training.

    use case 2 (knob tuning)
    
        > use knob_tune
        
        For spark, it should be
        
        > set_database spark
        > use knob_tune_spark
    """

    PilotConsole().console()
