{{ threshold_to_alarm(
    source_table=ref('int_heat_fridge_thresholds'),
    duration_threshold=600,
) }}
