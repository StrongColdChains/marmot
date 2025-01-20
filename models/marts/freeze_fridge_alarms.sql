{{ threshold_to_alarm(
    source_table=ref('int_freeze_fridge_thresholds'),
    duration_threshold=60,
) }}
