{{ interval_to_alarm(
    source_table=ref('int_door_intervals'),
    duration_threshold=5,
) }}
