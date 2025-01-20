{{ threshold_to_alarm(
    source_table=ref('int_power_thresholds'),
    duration_threshold=1440,
) }}
