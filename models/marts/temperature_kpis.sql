select
    cce_id,
    COUNT(*) as alarm_count,
    SUM(
        case
            when
                COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
                >= interval '48 hours'
                then 1
            else 0
        end
    ) as long_alarm_count,
    SUM(
        COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
    ) as cumulative_alarm_time,
    AVG(
        COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
    ) as average_alarm_time,
    MAX(
        COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin
    ) as longest_alarm_time,
    alarm_temperature_type,
    alarm_cce_type
from {{ ref('temperature_alarms') }}
where
    COALESCE(stop, '{{ var("now") }}'::timestamptz)
    >= '{{ var("now") }}'::timestamptz - interval '30 days'
group by cce_id, alarm_temperature_type, alarm_cce_type
