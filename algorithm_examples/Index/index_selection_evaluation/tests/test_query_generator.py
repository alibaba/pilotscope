import unittest

from selection.dbms.postgres_dbms import PostgresDatabaseConnector
from selection.query_generator import QueryGenerator
from selection.table_generator import TableGenerator


class TestQueryGenerator(unittest.TestCase):
    def setUp(self):
        self.db_name = None
        self.generating_connector = PostgresDatabaseConnector(None, autocommit=True)

    def tearDown(self):
        self.generating_connector.close()
        connector = PostgresDatabaseConnector(None, autocommit=True)

        if self.db_name is not None and connector.database_exists(self.db_name):
            connector.drop_database(self.db_name)

    def test_generate_tpch(self):
        self.db_name = "tpch_test_db"

        TableGenerator(
            "tpch",
            0.001,
            self.generating_connector,
            explicit_database_name=self.db_name,
        )

        db_connector = PostgresDatabaseConnector(self.db_name, autocommit=True)
        query_generator = QueryGenerator("tpch", 0.001, db_connector, None, [])
        queries = query_generator.queries
        self.assertEqual(len(queries), 22)
        db_connector.close()

    def test_generate_tpcds(self):
        self.db_name = "tpcds_test_db"

        TableGenerator(
            "tpcds",
            0.001,
            self.generating_connector,
            explicit_database_name=self.db_name,
        )

        db_connector = PostgresDatabaseConnector(self.db_name, autocommit=True)
        query_generator = QueryGenerator("tpcds", 1, db_connector, None, [])
        queries = query_generator.queries
        self.assertEqual(len(queries), 99)
        db_connector.close()

    def test_wrong_benchmark(self):
        with self.assertRaises(NotImplementedError):
            QueryGenerator("tpc-hallo", 1, self.generating_connector, None, [])


if __name__ == "__main__":
    unittest.main()
