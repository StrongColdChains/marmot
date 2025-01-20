{{ interval_to_alarm(
    source_table=ref('int_freeze_fridge_intervals'),
    duration_threshold=60,
) }}
