{{ interval_detection(
    source_table=ref('stg_temperature_ts'),
    time_column='created_at',
    float_column='temperature',
    identity_columns=['cce_id', 'monitor_id'],
    comparison_operator='<',
    threshold=-0.5,
    duration_threshold=60
) }}
