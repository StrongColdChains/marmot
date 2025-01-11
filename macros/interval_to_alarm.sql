{% macro interval_to_alarm(
    source_table
) %}

with alarms as (
    select
        begin_intervals.created_at as begin,
        begin_intervals.cce_id,
        begin_intervals.monitor_id,
        MIN(stop_intervals.created_at) as stop
    from {{ source_table }} as begin_intervals
    left join {{ source_table }} as stop_intervals
        on
            begin_intervals.created_at < stop_intervals.created_at
            and begin_intervals.alarm_status = 'begin'
            and stop_intervals.alarm_status = 'stop'
            and begin_intervals.cce_id = stop_intervals.cce_id
            and begin_intervals.monitor_id = stop_intervals.monitor_id
    where
        begin_intervals.alarm_status = 'begin'
    group by
        begin_intervals.cce_id,
        begin_intervals.monitor_id,
        begin_intervals.created_at
)

select *
from alarms
order by begin

{% endmacro %}