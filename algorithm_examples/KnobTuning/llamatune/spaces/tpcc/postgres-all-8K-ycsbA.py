# NOTE: Default values are gathered from PostgreSQL-9.6 on CloudLab c220g5

from spaces.common import finalize_conf, unfinalize_conf

KNOBS = [
    "autovacuum_vacuum_threshold",
    "autovacuum_vacuum_scale_factor",
    "commit_delay",
    "enable_seqscan",
    "full_page_writes",
    "geqo_selection_bias",
    "shared_buffers",
    "wal_writer_flush_after",
]
