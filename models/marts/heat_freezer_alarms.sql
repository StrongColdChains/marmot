{{ interval_to_alarm(
    source_table=ref('int_heat_freezer_intervals'),
    duration_threshold=60,
) }}
