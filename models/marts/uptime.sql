with merged_alarms_last_thirty_days as (
    select
        cce_id,
        island_id,
        MAX(interval_stop) - MIN(interval_begin) as actual_time_spent
    from {{ ref('uptime_islands') }}
    group by cce_id, island_id
)

select
    cce_id,
    (
        EXTRACT(epoch from interval '30 days')
        - EXTRACT(epoch from SUM(actual_time_spent))
    )
    / EXTRACT(epoch from interval '30 days')
    * 100 as uptime_percentage
from merged_alarms_last_thirty_days
group by cce_id
