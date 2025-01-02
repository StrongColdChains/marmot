-- Note: despite the intermediate calculations happening in different
-- models, all the various temperature WHO alarms will be consolidated
-- into a single model. This is because they are typically queried
-- together, reports want to know ALL the hot alarms, with some segmentation
-- happening deeper in the report, if at all.


with unioned_intervals as (
    select
        *,
        'heat' as alarm_temperature_type,
        'fridge' as alarm_cce_type
    from {{ ref('int_heat_fridge_intervals') }}
    union distinct
    select
        *,
        'freeze' as alarm_temperature_type,
        'fridge' as alarm_cce_type
    from {{ ref('int_freeze_fridge_intervals') }}
    union distinct
    select
        *,
        'heat' as alarm_temperature_type,
        'freezer' as alarm_cce_type
    from {{ ref('int_heat_freezer_intervals') }}
),

temperature_alarms as (
    select
        begin_intervals.created_at as begin,
        begin_intervals.cce_id,
        begin_intervals.monitor_id,
        begin_intervals.alarm_temperature_type,
        begin_intervals.alarm_cce_type,
        MIN(stop_intervals.created_at) as stop
    from unioned_intervals as begin_intervals
    left join unioned_intervals as stop_intervals
        on
            begin_intervals.created_at < stop_intervals.created_at
            and begin_intervals.alarm_status = 'begin'
            and stop_intervals.alarm_status = 'stop'
            and begin_intervals.cce_id = stop_intervals.cce_id
            and begin_intervals.monitor_id = stop_intervals.monitor_id
            and begin_intervals.alarm_cce_type = stop_intervals.alarm_cce_type
            and begin_intervals.alarm_temperature_type
            = stop_intervals.alarm_temperature_type
    where
        begin_intervals.alarm_status = 'begin'
    group by
        begin_intervals.cce_id,
        begin_intervals.monitor_id,
        begin_intervals.created_at,
        begin_intervals.alarm_temperature_type,
        begin_intervals.alarm_cce_type
)

select *
from temperature_alarms
order by alarm_temperature_type, alarm_cce_type, begin
