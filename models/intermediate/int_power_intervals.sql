{{ alarm_detection(
    source_table=ref('stg_power_ts'),
    time_column='created_at',
    float_column='power',
    partition_columns=['cce_id', 'monitor_id'],
    defined_alarms=[
        {
            'alarm_name': 'power_alarm',
            'comparison_operator': '<',
            'threshold': '1',
            'duration_threshold': '1440'
        }
    ]
) }}
