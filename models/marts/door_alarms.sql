{{ threshold_to_alarm(
    source_table=ref('int_door_thresholds'),
    duration_threshold=5,
) }}
