{% macro threshold_to_alarm(
    source_table,
    duration_threshold
) %}

with alarms as (
    select
        MIN(begin_thresholds.created_at) as begin,
        MIN(stop_thresholds.created_at) as stop,
        begin_thresholds.cce_id
    from {{ source_table }} as begin_thresholds
    left join {{ source_table }} as stop_thresholds
        on
            begin_thresholds.cce_id = stop_thresholds.cce_id
            and begin_thresholds.reset_group = stop_thresholds.reset_group
            and begin_thresholds.created_at <= stop_thresholds.created_at
            and stop_thresholds.threshold_is_crossed = FALSE
    group by
        begin_thresholds.reset_group,
        begin_thresholds.cce_id
    having
        MAX(begin_thresholds.cumulative_minutes) >= {{ duration_threshold }}
)

select
    begin,
    stop,
    cce_id,
    COALESCE(stop, '{{ var("now") }}'::timestamptz) - begin as duration
from alarms
order by begin

{% endmacro %}