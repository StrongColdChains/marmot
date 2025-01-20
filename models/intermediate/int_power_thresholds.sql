{{ threshold_detection(
    source_table=ref('stg_power_ts'),
    time_column='created_at',
    float_column='power',
    comparison_operator='<',
    threshold=1,
    duration_threshold=1440
) }}
