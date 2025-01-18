{% macro interval_to_alarm(
    source_table,
    duration_threshold
) %}

with alarms as (
    select
        -- TODO: make the following line work! Once I get internet I'm sure there's
        -- a way to get it working :p 
        {# begin_intervals.created_at - make_interval(mins => (begin_intervals.cumulative_minutes - {{ duration_threshold }})::int) as begin, #}
        begin_intervals.created_at - make_interval(secs => (begin_intervals.cumulative_minutes * 60)::int) as begin,
        {# begin_intervals.created_at as begin, #}
        begin_intervals.cce_id,
        MIN(stop_intervals.created_at) as stop
    from {{ source_table }} as begin_intervals
    left join {{ source_table }} as stop_intervals
        on
            begin_intervals.created_at <= stop_intervals.created_at
            and begin_intervals.begin = TRUE
            and stop_intervals.stop = TRUE
            and begin_intervals.cce_id = stop_intervals.cce_id
    where
        begin_intervals.begin = TRUE
    group by
        begin_intervals.cce_id,
        begin_intervals.created_at,
        begin_intervals.cumulative_minutes
)

select *
from alarms
order by begin

{% endmacro %}