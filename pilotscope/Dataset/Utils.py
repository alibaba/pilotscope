from pilotscope.PilotEnum import DatabaseEnum

sqlglot_str_mapping_table = {
    DatabaseEnum.POSTGRESQL: "postgres",
    DatabaseEnum.SPARK: "spark"
}


def database_enum_to_sqlglot_str(db_type):
    return sqlglot_str_mapping_table[db_type]
