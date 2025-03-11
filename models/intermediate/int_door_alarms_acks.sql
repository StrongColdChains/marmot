{{ add_acks(
    alarm_source_table=ref('int_door_alarms'),
    ack_source_table=ref('stg_ack_ts')
) }}
