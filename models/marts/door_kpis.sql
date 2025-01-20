select
    cce_id,
    COUNT(*) as alarm_count,
    SUM(
        COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
    ) as cumulative_alarm_time,
    AVG(
        COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
    ) as average_alarm_duration
from {{ ref('door_alarms') }}
where
    COALESCE(stop, '{{ var("now") }}'::timestamptz)
    >= '{{ var("now") }}'::timestamptz - interval '30 days'
group by cce_id
