import itertools

from selection.cost_evaluation import CostEvaluation
from selection.index import Index
from selection.workload import Column, Query, Table

table_A = Table("TableA")
column_A_0 = Column("Col0")
column_A_1 = Column("Col1")
column_A_2 = Column("Col2")
table_A.add_columns([column_A_0, column_A_1, column_A_2])

query_0 = Query(0, "SELECT * FROM TableA WHERE Col0 = 4;", [column_A_0])
query_1 = Query(
    1,
    "SELECT * FROM TableA WHERE Col0 = 1 AND Col1 = 2 AND Col2 = 3;",
    [column_A_0, column_A_1, column_A_2],
)

mock_cache = {}

table_A_potential_indexes = []
# Calculate potential indexes for TableA
for number_of_columns in range(1, len(table_A.columns) + 1):
    for column_list in itertools.permutations(table_A.columns, number_of_columns):
        table_A_potential_indexes.append(Index(column_list))

# Calculate relevant indexes for query_0 based on potential indexes
relevant_indexes_query1_table_A = CostEvaluation._relevant_indexes(
    query_0, table_A_potential_indexes
)

# Set cost for combinations of relevant indexes
for index_combination_size in range(0, len(relevant_indexes_query1_table_A) + 1):
    for index_combination in itertools.combinations(
        relevant_indexes_query1_table_A, index_combination_size
    ):
        # Each index with leading Col0 lowers the cost to 20
        if any([column_A_0 == index.columns[0] for index in index_combination]):
            mock_cache[(query_0, frozenset(index_combination))] = 20
            continue

        # Default cost without any beneficial index
        mock_cache[(query_0, frozenset(index_combination))] = 100

assert (
    mock_cache[(query_0, frozenset({Index([column_A_0])}))] == 20
), f"{mock_cache[(query_0, frozenset({Index([column_A_0])}))]} != 20"

# Calculate relevant indexes for query_1 based on potential indexes
relevant_indexes_query2_table_A = CostEvaluation._relevant_indexes(
    query_1, table_A_potential_indexes
)

# Set cost for combinations of relevant indexes
for index_combination_size in range(0, len(relevant_indexes_query2_table_A) + 1):
    for index_combination in itertools.combinations(
        relevant_indexes_query2_table_A, index_combination_size
    ):
        # Each index with leading Col0, Col1, Col2 lowers the cost to 20
        if any(
            [
                (column_A_0, column_A_1, column_A_2) == index.columns[:3]
                for index in index_combination
            ]
        ):
            mock_cache[(query_1, frozenset(index_combination))] = 20
            continue

        # Each index with leading Col0, Col1 lowers the cost to 25
        if any(
            [(column_A_0, column_A_1) == index.columns[:2] for index in index_combination]
        ):
            mock_cache[(query_1, frozenset(index_combination))] = 25
            continue
        # Each index with leading Col0, Col2 lowers the cost to 27
        if any(
            [(column_A_0, column_A_2) == index.columns[:2] for index in index_combination]
        ):
            mock_cache[(query_1, frozenset(index_combination))] = 27
            continue

        # Each index with leading Col0 lowers the cost to 30
        if any([column_A_0 == index.columns[0] for index in index_combination]):
            mock_cache[(query_1, frozenset(index_combination))] = 30
            continue
        # Each index with leading Col1 lowers the cost to 40
        if any([column_A_1 == index.columns[0] for index in index_combination]):
            mock_cache[(query_1, frozenset(index_combination))] = 40
            continue
        # Each index with leading Col2 lowers the cost to 50
        if any([column_A_2 == index.columns[0] for index in index_combination]):
            mock_cache[(query_1, frozenset(index_combination))] = 50
            continue

        # Default cost without any beneficial index
        mock_cache[(query_1, frozenset(index_combination))] = 150

assert (
    mock_cache[(query_1, frozenset({Index([column_A_0, column_A_1, column_A_2])}))] == 20
), f"{mock_cache[(query_1, frozenset({Index([column_A_0, column_A_1, column_A_2])}))]} != 20"  # noqa: E501


class MockConnector:
    def __init__(self):
        pass

    def drop_indexes(self):
        pass

    def simulate_index(self, potential_index):
        pass


class MockCostEvaluation:
    def __init__(self):
        pass
