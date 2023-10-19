pg_stats_test_result_table = "pg_stats_test_result"
base_time_statistic_file_path = "Results/"


def get_time_statistic_xlsx_file_path(algo_name, workload_name):
    return base_time_statistic_file_path + "{}_{}.xlsx".format(algo_name, workload_name)


def get_time_statistic_img_path(algo_name, workload_name):
    return "{}_{}".format(algo_name, workload_name)
