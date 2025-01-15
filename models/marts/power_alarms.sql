{{ interval_to_alarm(
    source_table=ref('int_power_intervals'),
    duration_threshold=1440,
) }}
