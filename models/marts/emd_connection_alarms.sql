{{ threshold_to_alarm(
    source_table=ref('int_emd_connection_thresholds'),
    duration_threshold=30,
) }}
