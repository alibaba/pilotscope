import unittest

from selection.dbms.postgres_dbms import PostgresDatabaseConnector
from selection.index import Index
from selection.table_generator import TableGenerator
from selection.workload import Column, Query, Table


class TestDatabase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_name = "tpch_test_db_database"
        db = PostgresDatabaseConnector(None, autocommit=True)
        TableGenerator("tpch", 0.001, db, explicit_database_name=cls.db_name)
        db.close()

    @classmethod
    def tearDownClass(cls):
        connector = PostgresDatabaseConnector(None, autocommit=True)
        if connector.database_exists(cls.db_name):
            connector.drop_database(cls.db_name)

    def test_postgres_index_simulation(self):
        db = PostgresDatabaseConnector(self.db_name, "postgres")
        self.assertTrue(db.supports_index_simulation())
        db.close()

    def test_simple_statement(self):
        db = PostgresDatabaseConnector(self.db_name, "postgres")

        statement = "select count(*) from nation"
        result = db.exec_fetch(statement)
        self.assertEqual(result[0], 25)

        db.close()

    def test_runtime_data_logging(self):
        db = PostgresDatabaseConnector(self.db_name, "postgres")

        query = Query(17, "SELECT count(*) FROM nation;")
        db.get_cost(query)
        self.assertEqual(db.cost_estimations, 1)
        self.assertGreater(db.cost_estimation_duration, 0)

        column_n_name = Column("n_name")
        nation_table = Table("nation")
        nation_table.add_column(column_n_name)
        index = Index([column_n_name])
        index_oid = db.simulate_index(index)[0]
        self.assertGreater(db.index_simulation_duration, 0)
        self.assertEqual(db.simulated_indexes, 1)

        previou_simulation_duration = db.index_simulation_duration
        db.drop_simulated_index(index_oid)
        self.assertGreater(db.index_simulation_duration, previou_simulation_duration)


if __name__ == "__main__":
    unittest.main()
