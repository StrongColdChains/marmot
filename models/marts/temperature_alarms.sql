-- Note: despite the intermediate calculations happening in different
-- models, all the various temperature WHO alarms will be consolidated
-- into a single model. This is because they are typically queried
-- together, reports want to know ALL the hot alarms, with some segmentation
-- happening deeper in the report, if at all.


-- TODO: this is getting too unwieldy to manage separately. Needs to be refactored
-- back into the macros.
with unioned_intervals as (
    select
        *,
        'heat' as alarm_temperature_type,
        'fridge' as alarm_cce_type,
        600 as duration
    from {{ ref('int_heat_fridge_intervals') }}
    union distinct
    select
        *,
        'freeze' as alarm_temperature_type,
        'fridge' as alarm_cce_type,
        60 as duration
    from {{ ref('int_freeze_fridge_intervals') }}
    union distinct
    select
        *,
        'heat' as alarm_temperature_type,
        'freezer' as alarm_cce_type,
        60 as duration
    from {{ ref('int_heat_freezer_intervals') }}
),

temperature_alarms as (
    select
        -- TODO: implement the logic here buddy
        begin_intervals.created_at as begin,
        begin_intervals.cce_id,
        begin_intervals.alarm_temperature_type,
        begin_intervals.alarm_cce_type,
        MIN(stop_intervals.created_at) as stop
    from unioned_intervals as begin_intervals
    left join unioned_intervals as stop_intervals
        on
            begin_intervals.created_at <= stop_intervals.created_at
            and begin_intervals.begin = TRUE
            and stop_intervals.stop = TRUE
            and begin_intervals.cce_id = stop_intervals.cce_id
            and begin_intervals.alarm_cce_type = stop_intervals.alarm_cce_type
            and begin_intervals.alarm_temperature_type
            = stop_intervals.alarm_temperature_type
    where
        begin_intervals.begin = TRUE
    group by
        begin_intervals.cce_id,
        begin_intervals.created_at,
        begin_intervals.cumulative_minutes,
        begin_intervals.duration,
        begin_intervals.alarm_temperature_type,
        begin_intervals.alarm_cce_type
)

select *
from temperature_alarms
order by alarm_temperature_type, alarm_cce_type, begin
