{{ interval_detection(
    source_table=ref('stg_power_ts'),
    time_column='created_at',
    float_column='power',
    identity_columns=['cce_id', 'monitor_id'],
    comparison_operator='<',
    threshold=1,
    duration_threshold=1440
) }}
