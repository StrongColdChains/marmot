{{ interval_to_alarm(
    source_table=ref('int_emd_connection_intervals'),
    duration_threshold=30,
) }}
