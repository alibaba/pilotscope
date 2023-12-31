import unittest

from pilotscope.DBController.SparkSQLController import SparkSQLController, SparkConfig, SparkSQLDataSourceEnum
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PostgreSQLConfig


class MyTestCase(unittest.TestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)

    def setUp(self):
        self.config = SparkConfig(
            app_name="testApp",
            master_url="local[*]"
        )
        self.config.use_postgresql_datasource(
            db_host='localhost',
            db_port="5432",
            db_user='pilotscope',
            db_user_pwd='pilotscope',
            db='stats_tiny',
        )
        self.config.set_spark_session_config({
            "spark.sql.pilotscope.enabled": True,
            "spark.executor.memory": "20g"
        })
        self.table_name = "lero"
        self.db_controller: SparkSQLController = DBControllerFactory.get_db_controller(self.config)
        self.sql = "select * from badges limit 10;"
        self.table = "badges"
        self.column = "date"
        self.db_controller._connect_if_loss()

    def test_get_hint_sql(self):
        # print(self.db_controller.connection.sparkContext.getConf().getAll())
        self.db_controller.load_all_tables_from_datasource()
        self.db_controller.set_hint("spark.sql.autoBroadcastJoinThreshold", "1234")
        self.db_controller.set_hint("spark.execution.memory", "1234")

    def test_create_table(self):
        # self.db_controller.load_all_tables_from_datasource()
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        # self.db_controller.connect_if_loss()
        self.db_controller.create_table_if_absences("test_create_table", {"ID": 1, "name": "Tom"})
        self.assertTrue(self.db_controller.exist_table("test_create_table"))
        self.db_controller.clear_all_tables()

    def test_insert(self):
        self.db_controller.create_table_if_absences("test_create_table", {"ID": 1, "name": "Tom"})
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        self.db_controller.create_table_if_absences("test_create_table", {"ID": 1, "name": "Tom"})
        assert (self.db_controller.get_table_row_count("test_create_table") == 0)
        self.db_controller.persist_tables()

        self.db_controller.insert("test_create_table", {"ID": 1, "name": "Tom"}, persist=False)
        assert (self.db_controller.get_table_row_count("test_create_table") == 1)
        self.db_controller.clear_all_tables()
        # as the insertion above was not persisted, here the table will still be empty
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        assert (self.db_controller.get_table_row_count("test_create_table") == 0)

        self.db_controller.insert("test_create_table", {"ID": 1, "name": "Tom"}, persist=True)
        print(self.db_controller.get_table_row_count("test_create_table"))
        assert (self.db_controller.get_table_row_count("test_create_table") == 1)
        self.db_controller.clear_all_tables()
        # as the insertion above was persisted, here the table will be non-empty
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        assert (self.db_controller.get_table_row_count("test_create_table") == 1)

        # reset the table status
        self.db_controller.name_2_table["test_create_table"].clear_rows(self.db_controller.engine, persist=True)
        self.db_controller.clear_all_tables()

        pg_db_controller = DBControllerFactory.get_db_controller(
            PostgreSQLConfig(db_host=self.config.db_host, db_port=self.config.db_port,
                             db_user=self.config.db_user, db_user_pwd=self.config.db_user_pwd,
                             db=self.config.db))
        pg_db_controller.drop_table_if_exist("test_create_table")  # clean table for testing next time

    def test_set_and_recover_knobs(self):
        # self.db_controller.load_all_tables_from_datasource()
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        # self.db_controller.connect_if_loss()

        self.db_controller.write_knob_to_file(
            {"spark.sql.ansi.enabled": "true", "spark.sql.autoBroadcastJoinThreshold": "1234"})
        assert (self.db_controller._get_connection().conf.get("spark.sql.ansi.enabled") == 'true')
        assert (self.db_controller._get_connection().conf.get("spark.sql.autoBroadcastJoinThreshold") == '1234')

        self.db_controller.recover_config()
        assert (self.db_controller._get_connection().conf.get("spark.sql.ansi.enabled") == 'false')
        assert (self.db_controller._get_connection().conf.get("spark.sql.autoBroadcastJoinThreshold") == '10485760b')
        self.db_controller.clear_all_tables()

    def test_execute(self):
        # self.db_controller.load_all_tables_from_datasource()
        self.db_controller.load_table_if_exists_in_datasource("test_create_table")
        self.db_controller.load_table_if_exists_in_datasource("badges")
        self.db_controller.load_table_if_exists_in_datasource("posts")
        # self.db_controller.connect_if_loss()
        res = self.db_controller.execute(
            '/*pilotscope {"anchor": {"EXECUTION_TIME_PULL_ANCHOR": {"enable": true, "name": "EXECUTION_TIME_PULL_ANCHOR"}}, "enableTerminate": true, "enableReceiveData": false, "port": 57205, "url": "localhost", "tid": "140335169763072"} pilotscope*/ select  count(*) from badges as b,     posts as p where b.userid = p.owneruserid  AND p.posttypeid=2  AND p.score>=0  AND p.score<=20  AND p.commentcount<=12;',
            True
        )
        print("res: ", res)
        self.db_controller.clear_all_tables()


if __name__ == '__main__':
    unittest.main(warnings='ignore')
