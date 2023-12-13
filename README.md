# <center><font color=green size=10>PilotScope</font></center>
<div style="text-align:center">
  <img src="fig/banner.png", alt="PilotScope" />
</div>

![](https://img.shields.io/badge/language-Python-blue.svg)
![](https://img.shields.io/badge/language-C-blue.svg)
![](https://img.shields.io/badge/language-Scala-blue.svg)
![](https://img.shields.io/badge/license-Apache_2.0-000000.svg) ![](https://img.shields.io/badge/contributions-Welcome-brightgreen.svg)

![](https://img.shields.io/badge/docs-Usage_Guideline-purple.svg)
![](https://img.shields.io/badge/docs-Develop_Guideline-purple.svg)
![](https://img.shields.io/badge/docs-API_Reference-purple.svg)

![](https://img.shields.io/badge/AI4DB_driver-Knob_Tuning-4E29FF.svg)
![](https://img.shields.io/badge/AI4DB_driver-Index_Recommendation-4E29FF.svg)
![](https://img.shields.io/badge/AI4DB_driver-Cardinality_Estimation-4E29FF.svg)
![](https://img.shields.io/badge/AI4DB_driver-E2E_Query_Optimizer-4E29FF.svg)

![](https://img.shields.io/badge/database-PostgreSQL_13.1-FFD21E.svg)
![](https://img.shields.io/badge/database-Spark_3.1-FFD21E.svg)

**PilotScope** is a middleware to bridge the gaps of deploying AI4DB (Artificial Intelligence for Databases) algorithms into actual database systems. It aims at hindering the underlying details of different databases so that an AI4DB driver could steer any database in a unified manner. By applying PilotScope, we obtain the following benefits:

* The DB users could experience any AI4DB algorithm as a plug-in unit on their databases with little cost. The cloud computing service providers could operate and maintain AI4DB algorithms on their database products as a service to users. **(More Convenient for Usage! 👏👏👏)**

* The ML researchers could easily benchmark and iterate their AI4DB algorithms in practical scenarios. **(Much Faster to Iterate! ⬆️⬆️⬆️)**

* The ML and DB developers are liberated from learning the details in other side. They could play their own strengthes to write the codes in their own sides. **(More Freedom to Develop! 🏄‍♀️🏄‍♀️🏄‍♀️)**


* All contributors could extend PilotScope to support more AI4DB algorithms, more databases and more functions. **(We highly encourage this! 😊😊😊)**


| [Code Structure](#code-structure) | [Quick Start](#quick-start) | [Core Components](#core-components) | [Example](#example) | [Documentation](#documentation) | [License](#license) | [Publication](#publications) | [Contributing](#contributing) | 

---
**News**

* 🎉 [2023-12-15] Our **[paper](https://)** on PilotScope has been accepted by VLDB 2024!

---
<!-- ## News -->
## Code Structure
```
PilotScope/
├── cacheData                               
├── common                                  # Useful tools for PilotScope
│   ├── Cache.py
│   ├── dotDrawer.py
│   ├── ...
├── components                              
│   ├── Anchor                              # Base anchors and implementation of specific anchors       
│   │   ├── BaseAnchor
│   │   ├── AnchorTransData.py
│   │   ├── ...
│   ├── Dao                                 # Management of user's data and training data
│   │   ├── PilotTrainDataManager.py
│   │   └── PilotUserDataManager.py
│   ├── DataFetcher                         # Details of the entire process about fetching data. 
│   │   ├── BaseDataFetcher.py
│   │   ├── HttpDataFetch.py
│   │   ├── PilotCommentCreator.py
│   │   └── PilotStateManager.py
│   ├── DBController                        # Base controllers of DB and implementation of specific controllers
│   │   ├── BaseDBController.py
│   │   ├── PostgreSQLController.py
│   │   └── SparkSQLController.py
│   ├── Exception                           # Some exception which may occur in the lifecycle of pilotscope
│   │   └── Exception.py
│   ├── Factory                             # Factory patterns
│   │   ├── AnchorHandlerFactory.py
│   │   ├── DataFetchFactory.py
│   │   ├── ...
│   ├── PilotConfig.py                      # Configurations for specific databases
│   ├── PilotEnum.py                        # Enumeration types
│   ├── PilotEvent.py                       # Base events of pilotscope
│   ├── PilotModel.py                       # Base models of pilotscope
│   ├── PilotScheduler.py                   # Sheduling data traing、inference、collection push-and-pull and so on
│   ├── PilotSysConfig.py                   # Configuration for data collection and storage
│   ├── PilotTransData.py                   # Parsing and storing data
│   └── Server                              # HTTP server for receiving data
│       └── Server.py                       
├── test_example_algorithm                  # Examples of some tasks and models
└── test_pilotscope                         # Unittests of PilotScope
```
## Quick Start
The quick start guide is available in [documentation](http://gitlab.alibaba-inc.com/baihe-dev/PilotScopeDocs.git).

## Core Components
The components of PilotScope Core in ML side can be divided into two categories: Database Components and Deployment Components. The Database Components are used to facilitate data exchange and control over database, while the Deployment Components are used to facilitate the automatic application of custom AI algorithms to each incoming SQL query. 

A high-level overview of the PilotScope Core components is shown in the following figure.

<div align="center">
  <img src="fig/pilotscope_module_framework.png" alt="PilotScope" style="width: 80%;" />
</div>

The Database Components are highlighted in Yellow, while the Deployment Components are highlighted in green. We will discuss each of these components in detail in the following sections.


To facilitate data exchange and control over database, PilotScope incorporates the following components:

- `PilotConfig`: It is utilized to configure the PilotScope application. It includes various configurations such as the
  database credentials for establishing a connection, the runtime settings such as timeout duration, and more.
- `PilotDataInteractor`: This component provides a flexible workflow for data exchange. It includes three main
  functions: push, pull, and execute. These functions assist the user in collecting data (pull operators) after setting
  additional data (push operators) in a single query execution process.
- `DBController`: It provides a powerful and unified ability to control various databases. It supports various
  functionalities such as setting knobs, creating indexes, restarting databases, and more.

### PilotConfig
The `PilotConfig` class is utilized to configure the PilotScope application.
It includes various configurations such as the database credentials for establishing a connection, the runtime settings
such as timeout duration, and more.

To quickly connect PilotScope to a PostgreSQL database named `stats_tiny`, the user can use the following code:

```python
# Example of PilotConfig
config: PilotConfig = PostgreSQLConfig(host="localhost", port="5432", user="postgres", pwd="postgres")
# You can also instantiate a PilotConfig for other DBMSes. e.g. 
# config:PilotConfig = SparkConfig()
config.db = "stats_tiny"
# Configure PilotScope here, e.g. changing the name of database you want to connect to.
```

In the above code, the `stats_tiny` database is accessed using the username `postgres` and the password `postgres`.
The database is located on the `localhost` machine with port number `5432`.

In certain scenarios, when the user needs to perform more complex functionalities like restarting the database (usually
in Knob tuning tasks),
additional configurations related to the installation information of the database are required.

To enable deep control functionality, the user can utilize the `enable_deep_control_local`
or `enable_deep_control_remote` method in the PilotConfig class.
Those 2 methods take in several parameters related to the database installation information. If the PostgreSQL database
and the ML side program are running on the same machine,
please use `enable_deep_control_local`. Otherwise, use `enable_deep_control_remote`. Here is an example code snippet:

```python
# pg_bin_path: The directory of binary file of postgresql, i.e. the path of 'postgres', 'pg_ctl' etc.
# pg_data_path: The path to the PostgreSQL data directory (pgdata) where the database files are stored.
config.enable_deep_control_local(pg_bin_path, pg_data_path)
```

For remote control, you will need to connect to the remote machine via SSH for control.
In addition to the parameters mentioned above, you will also need the username, password, and SSH port of the remote
machine.

```python
# db_host_user: The username to log in to the machine with database.
# db_host_pwd: The corresponding password
# db_host_ssh_port:  SSH port of the remote machine.
config.enable_deep_control_remote(pg_bin_path, pg_data_path, db_host_user, db_host_pwd, db_host_ssh_port)
```

### PilotDataInteractor

The PilotDataInteractor class provides a flexible workflow for data exchange. It includes three main functions: push,
pull, and execute.
These functions assist the user in collecting data (pull operators) after setting additional data (push operators) in a
single query execution process.

Specifically, the `pull` and `push` functions are used to register information related to data collection and settings.
It is important to note that they are used to register information, and do not trigger the execution of a query.

To execute a SQL query, the user needs to call the `execute` function.
This function triggers the actual execution of the query and retrieves the desired information.

For instance, if the user wants to collect the execution time, estimated cost, and cardinality of all sub-queries within
a query. Here is an example code:

```python
sql = "select count(*) from votes as v, badges as b, users as u where u.id = v.userid and v.userid = b.userid and u.downvotes>=0 and u.downvotes<=0"
data_interactor = PilotDataInteractor(config)
data_interactor.pull_estimated_cost()
data_interactor.pull_subquery_card()
data_interactor.pull_execution_time()
data = data_interactor.execute(sql)
print(data)
```

The `execute` function returns a `PilotTransData` object named `data`, which serves as a placeholder for the collected
data.
Each member of this object represents a specific data point, and the values corresponding to the previously
registered `pull` operators will be filled in, while the other values will remain as None.

```
execution_time: 0.00173
estimated_cost: 98.27
subquery_2_card: {'select count(*) from votes v': 3280.0, 'select count(*) from badges b': 798.0, 'select count(*) from users u where u.downvotes >= 0 and u.downvotes <= 0': 399.000006, 'select count(*) from votes v, badges b where v.userid = b.userid;': 368.609177, 'select count(*) from votes v, users u where v.userid = u.id and u.downvotes >= 0 and u.downvotes <= 0;': 333.655156, 'select count(*) from badges b, users u where b.userid = u.id and u.downvotes >= 0 and u.downvotes <= 0;': 425.102804, 'select count(*) from votes v, badges b, users u where v.userid = u.id and v.userid = b.userid and u.downvotes >= 0 and u.downvotes <= 0;': 37.536205}
buffercache: None
...
```

In certain scenarios, when the user wants to collect the execution time of a SQL query after applying a new
cardinality (e.g., scaling the original cardinality by 100) for all sub-queries within the SQL,
the PilotDataInteractor provides push function to achieve this.
Here is an example code:

```python
# Example of PilotDataInteractor (registering operators again and execution)
data_interactor.push_card({k: v * 100 for k, v in data.subquery_2_card.items()})
data_interactor.pull_estimated_cost()
data_interactor.pull_execution_time()
new_data = data_interactor.execute(sql)
print(new_data)
```

By default, each call to the execute function will reset any previously registered operators.
Therefore, we need to push these new cardinalities and re-register the pull operators to collect the estimated cost and
execution time.
In this scenario, the new cardinalities will replace the ones estimated by the database's cardinality estimator.
As a result, the partial result of the `new_data` object will be significantly different from the result of the `data`
object,
mainly due to the variation in cardinality values.

```
execution_time: 0.00208
estimated_cost: 37709.05
...
```

### DBController

The DBController class provides a powerful and unified ability to control various databases.
It supports various functionalities such as setting knobs, creating indexes, restarting databases, and more.
Here is an example code that demonstrates how to use it:

```python
# Example of DBController
db_controller: BaseDBController = DBControllerFactory.get_db_controller(self.config)

# Restarting the database
db_controller.restart()
```

In this example, we first create an instance of the DBController class by calling DBControllerFactory.get_db_controller
and passing in the necessary configuration.
This will return an object that implements the BaseDBController interface. Such as PostgreSQLDBController,
SparkDBController, etc.
Next, we can use the db_controller object to perform various operations on the database.
In this case, we call the restart method to restart the database.

When instantiating using a factory, the default value for  ``enable_simulate_index`` is False. However,
setting ``enable_simulate_index`` to True will transform all index operations into operations on hypothetical indexes.
Please note that in order to use hypothetical indexes, the connected database must have
the `HypoPG <https://github.com/HypoPG/hypopg>`_ extension installed.

```python
db_controller: PostgreSQLController = DBCntrollerFactory.get_db_controller(config, enable_simulate_index=True)
res = db_controller.get_all_indexes()
index = Index(["date"], "badges", index_name="index_name")
db_controller.create_index(index)
print(db_controller.get_all_indexes())
```

The Hypothetical indexes created with HypoPG are effective only within a single connection. Once the connection is
reset, all hypothetical indexes will be lost. Also, since the hypothetical indexes doesn’t really exists, HypoPG makes
sure they will only be used using a simple EXPLAIN statement without the ANALYZE option in PostgreSQL terminal (
so ``explain_physical_plan`` and ``get_estimated_cost`` can work). In our implementations, if hypothetical indexes are
enabled, all real indexes are hidden.

It's important to distinguish that `PilotDataInteractor` is designed to collect data when executing SQL queries, while
the `DBController` class is specifically focused on providing control over the database itself.
`PilotDataInteractor` is also implemented based on the functionality provided by `DBController`.

## Example
### Knob Tuning Task Example
We provide a Bayesian optimization method called SMAC as our example. You can try the example by running:
```python
python test_knob_example.py
```
### Index Recommendation Task Example
Index recommendation task is similar to knob tuning, where an algorithm interacts with a database to complete the task before the actual execution. The difference is that this task involves selecting an index. You can try the example by running:
```python
python test_index_example.py
```
### Cardinality Estimation Task Example
Unlike the knob tuning task and index recommendation task, the cardinality estimation algorithm is triggered by each SQL. You can try the example by running:
```python
python test_mscn_example.py
```

### Query Optimizer Task Example
Like the cardinality estimation task, the query optimizer task is triggered by each SQL query. And the query optimizer task is to select the efficient plan of the user query to execute. You can try the example by running:
```python
python test_lero_example.py
```

## Documentation
The classes and methods of FederatedScope have been well documented. You can find the documentation in [documentation](http://gitlab.alibaba-inc.com/baihe-dev/PilotScopeDocs.git).
## License
PilotScope is released under Apache License 2.0.
## Publications
If you find PilotScope useful for your research or development, please cite the following [paper]():
```
```
## Contributing
As an open-sourced project, we greatly appreciate any contribution to PilotScope! 