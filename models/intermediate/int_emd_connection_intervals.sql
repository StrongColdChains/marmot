{{ alarm_detection(
    source_table=ref('stg_emd_connection_ts'),
    time_column='created_at',
    float_column='connected',
    partition_columns=['cce_id', 'monitor_id'],
    defined_alarms=[
        {
            'alarm_name': 'emd_disconnection_alarm',
            'comparison_operator': '<',
            'threshold': '1',
            'duration_threshold': '30'
        }
    ]
) }}
