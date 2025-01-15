{{ interval_detection(
    source_table=ref('stg_temperature_ts'),
    time_column='created_at',
    float_column='temperature',
    identity_columns=['cce_id', 'monitor_id'],
    defined_alarms=[
        {
            'alarm_name': 'heat_fridge_alarm',
            'comparison_operator': '>',
            'threshold': '8',
            'duration_threshold': '600'
        }
    ]
) }}
