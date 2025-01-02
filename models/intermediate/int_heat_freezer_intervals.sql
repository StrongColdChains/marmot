{{ alarm_detection(
    source_table=ref('stg_temperature_ts'),
    time_column='created_at',
    float_column='temperature',
    partition_columns=['cce_id', 'monitor_id'],
    defined_alarms=[
        {
            'alarm_name': 'heat_freezer_alarm',
            'comparison_operator': '>',
            'threshold': '-15',
            'duration_threshold': '60'
        }
    ]
) }}
