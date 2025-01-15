{{ interval_detection(
    source_table=ref('stg_emd_connection_ts'),
    time_column='created_at',
    float_column='connected',
    identity_columns=['cce_id', 'monitor_id'],
    comparison_operator='<',
    threshold=1,
    duration_threshold=30
) }}
