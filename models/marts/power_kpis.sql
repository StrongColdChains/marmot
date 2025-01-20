with normal_kpis as (
    select
        cce_id,
        COUNT(*) as alarm_count,
        SUM(duration) as cumulative_alarm_time,
        AVG(duration) as average_alarm_time
    from {{ ref('power_alarms') }}
    where
        COALESCE(stop, '{{ var("now") }}'::timestamptz)
        >= '{{ var("now") }}'::timestamptz - interval '30 days'
    group by cce_id
),

thresholds_with_minutes_until as (
    select
        cce_id,
        EXTRACT(epoch from (
            LEAD(created_at, 1, '{{ var("now") }}'::timestamptz)
                over (
                    partition by cce_id
                    order by created_at
                )
            - created_at
        )) / 60.0 as minutes_until_next_datapoint,
        threshold_is_crossed
    from {{ ref('int_power_thresholds') }}
    where created_at >= '{{ var("now") }}'::timestamptz - interval '30 days'
),

threshold_kpis as (
    select
        cce_id,
        SUM(minutes_until_next_datapoint) as minutes_power_active
    from thresholds_with_minutes_until
    where threshold_is_crossed = FALSE
    group by cce_id
)

select
    n.cce_id,
    n.alarm_count,
    n.cumulative_alarm_time,
    n.average_alarm_time,
    i.minutes_power_active
from normal_kpis as n inner join threshold_kpis as i
    on n.cce_id = i.cce_id
