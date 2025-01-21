select
    cce_id,
    (
        extract(epoch from interval '15 days')
        / extract(epoch from interval '30 days')
    ) as uptime_percentage
from {{ ref('all_alarms') }}
group by cce_id
