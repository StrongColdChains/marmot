select
    cce_id,
    COUNT(*) as alarm_count,
    SUM(
        case
            when
                duration >= interval '48 hours'
                then 1
            else 0
        end
    ) as long_alarm_count,
    SUM(duration) as cumulative_alarm_time,
    AVG(duration) as average_alarm_time,
    MAX(duration) as longest_alarm_time
from {{ ref('freeze_fridge_alarms') }}
where
    COALESCE(stop, '{{ var("now") }}'::timestamptz)
    >= '{{ var("now") }}'::timestamptz - interval '30 days'
group by cce_id
