class CardPicker():
    def __init__(self, rows_arr, table_arr,
                 swing_factor_lower_bound=0.1**2, swing_factor_upper_bound=10**2, swing_factor_step=10) -> None:
        self.rows_arr = rows_arr
        self.table_arr = table_arr

        # Mapping the number of table in sub-query to the index of its cardinality in rows_arr
        self.table_num_2_card_idx_dict = {}
        for i, tables in enumerate(self.table_arr):
            table_num = len(tables)
            if table_num not in self.table_num_2_card_idx_dict:
                self.table_num_2_card_idx_dict[table_num] = []
            self.table_num_2_card_idx_dict[table_num].append(i)
        self.max_table_num = max(self.table_num_2_card_idx_dict.keys())

        # Each time we will adjust all the cardinalities of sub-queries in the same group (group by the number of table here)
        # And adjust according to the number of tables from more to less, 
        # because the more complex the execution plan is, the more likely it is to produce wrong estimates on cardinality
        self.cur_sub_query_table_num = self.max_table_num
        self.cur_sub_query_related_card_idx_list = self.table_num_2_card_idx_dict[self.cur_sub_query_table_num]

        # create the swing factor list 
        assert swing_factor_lower_bound < swing_factor_upper_bound
        self.swing_factor_lower_bound = swing_factor_lower_bound
        self.swing_factor_upper_bound = swing_factor_upper_bound
        self.step = swing_factor_step
        self.sub_query_swing_factor_index = 0

        self.swing_factors = set()
        cur_swing_factor = 1
        while cur_swing_factor <= self.swing_factor_upper_bound:
            self.swing_factors.add(cur_swing_factor)
            cur_swing_factor *= self.step
        self.swing_factors.add(self.swing_factor_upper_bound)

        cur_swing_factor = 1
        while cur_swing_factor >= self.swing_factor_lower_bound:
            self.swing_factors.add(cur_swing_factor)
            cur_swing_factor /= self.step
        self.swing_factors.add(self.swing_factor_lower_bound)
        self.swing_factors = list(self.swing_factors)

        # indicates whether all combinations have been tried
        self.finish = False

    def get_card_list(self):
        if len(self.cur_sub_query_related_card_idx_list) == 0:
            self.cur_sub_query_related_card_idx_list = self.table_num_2_card_idx_dict[self.cur_sub_query_table_num]

        cur_swing_factor = self.swing_factors[self.sub_query_swing_factor_index]

        new_rows_arr = [float(item) for item in self.rows_arr]
        for join_idx in self.cur_sub_query_related_card_idx_list:
            new_rows_arr[join_idx] = float(int(new_rows_arr[join_idx] * cur_swing_factor))

        return new_rows_arr

    def next(self):
        self.sub_query_swing_factor_index += 1
        if self.sub_query_swing_factor_index == len(self.swing_factors):
            self.sub_query_swing_factor_index = 0
            self.cur_sub_query_table_num -= 1
            self.cur_sub_query_related_card_idx_list = []

        if self.cur_sub_query_table_num <= 1:
            self.cur_sub_query_table_num = self.max_table_num
            self.finish = True

        return self.finish