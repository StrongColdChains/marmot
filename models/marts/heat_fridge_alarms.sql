{{ interval_to_alarm(
    source_table=ref('int_heat_fridge_intervals'),
    duration_threshold=600,
) }}
