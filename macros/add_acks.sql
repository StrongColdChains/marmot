{% macro add_acks(
    alarm_source_table,
    ack_source_table
) %}

select
    al.cce_id,
    al.begin as alarm_start,
    al.stop as alarm_stop,
    al.duration as alarm_duration,
    a.ack_created_at,
    a.ack_received_at
from {{alarm_source_table}} al
left join lateral (
    select
        ac.cce_id,
        ac.created_at as ack_created_at,
        ac.received_at as ack_received_at
    from {{ack_source_table}} ac
    where al.cce_id = ac.cce_id
    and al.begin <= ac.created_at
    order by ac.created_at asc
    limit 1
) a on true


{% endmacro %}