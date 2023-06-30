def index_combination_to_str(index_combination):
    indexes_as_str = sorted([x.index_idx() for x in index_combination])

    return "||".join(indexes_as_str)
