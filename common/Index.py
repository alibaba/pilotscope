class Index:
    def __init__(self, columns: list, table, index_name=None, index_method=None):
        if len(columns) == 0:
            raise ValueError("Index needs at least 1 column")
        self.columns = tuple(columns)
        self.table = table
        self.index_name = index_name

        # used by simulate index (what if)
        self.hypopg_oid = None
        self.hypopg_name = None

    # Used to sort indexes
    def __lt__(self, other):
        if len(self.columns) != len(other.columns):
            return len(self.columns) < len(other.columns)

        return self.columns < other.columns

    def __repr__(self):
        columns_string = ",".join(map(str, self.columns))
        return f"{self.table}: {columns_string}"

    def __eq__(self, other):
        if not isinstance(other, Index):
            return False

        return self.columns == other.columns

    def __hash__(self):
        return hash(self.columns)

    def _column_names(self):
        return [x for x in self.columns]

    def is_single_column(self):
        return True if len(self.columns) == 1 else False

    def index_idx(self):
        return self.get_index_name()

    def get_index_name(self):
        if self.index_name is not None:
            return self.index_name
        columns = "_".join(self._column_names())
        return f"{self.table}_{columns}_idx"

    def joined_column_names(self):
        return ",".join(self._column_names())

    def appendable_by(self, other):
        if not isinstance(other, Index):
            return False

        if self.table() != other.table():
            return False

        if not other.is_single_column():
            return False

        if other.columns[0] in self.columns:
            return False

        return True

    def subsumes(self, other):
        if not isinstance(other, Index):
            return False
        return self.columns[: len(other.columns)] == other.columns

    def prefixes(self):
        """Consider I(K;S). For any prefix K' of K (including K' = K if S is not
        empty), an index I_P = (K';Ø) is obtained.
        Returns a list of index prefixes ordered by decreasing width."""
        index_prefixes = []
        for prefix_width in range(len(self.columns) - 1, 0, -1):
            index_prefixes.append(Index(self.columns[:prefix_width]))
        return index_prefixes
