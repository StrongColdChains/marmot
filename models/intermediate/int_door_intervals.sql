{{ interval_detection(
    source_table=ref('stg_door_ts'),
    time_column='created_at',
    float_column='door_open',
    comparison_operator='>',
    threshold='0',
    duration_threshold='5'
) }}
