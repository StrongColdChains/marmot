{{ threshold_to_alarm(
    source_table=ref('int_heat_freezer_thresholds'),
    duration_threshold=60,
) }}
