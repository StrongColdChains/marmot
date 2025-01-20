select
    monitor_id,
    SUM(lateness) as cumulative_lateness,
    AVG(lateness) as average_lateness,
    MAX(lateness) as max_lateness,
    COUNT(
        case
            when lateness > interval '0 minutes' then 1
        end
    )::float / COUNT(*)::float as percentage_late
from {{ ref('int_connectivity') }}
where
    received_at >= '{{ var("now") }}'::timestamptz - interval '30 days'
group by monitor_id
