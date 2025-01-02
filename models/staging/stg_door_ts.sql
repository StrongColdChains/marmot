with

source as (
    select * from {{ source('public', 'raw_door') }}
),

retyped as (
    select
        -- ids
        cce_id,
        monitor_id,
        -- sensor reading
        CAST(door_open as INTEGER) as door_open,
        -- time
        CAST(t as TIMESTAMP) as created_at,
        CAST(rt as TIMESTAMP) as received_at

    from source
)

select * from retyped
