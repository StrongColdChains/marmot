{% macro interval_to_alarm(
    source_table,
    duration_threshold
) %}

with alarms as (
    select
        MIN(begin_intervals.created_at) as begin,
        MIN(stop_intervals.created_at) as stop,
        begin_intervals.cce_id
    from {{ source_table }} as begin_intervals
    left join {{ source_table }} as stop_intervals
        on
            begin_intervals.cce_id = stop_intervals.cce_id
            and begin_intervals.reset_group = stop_intervals.reset_group
            and begin_intervals.created_at <= stop_intervals.created_at
            and stop_intervals.threshold_is_crossed = FALSE
    group by
        begin_intervals.reset_group,
        begin_intervals.cce_id
    having
        MAX(begin_intervals.cumulative_minutes) >= {{ duration_threshold }}
)

select *
from alarms
order by begin

{% endmacro %}