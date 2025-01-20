with

source as (
    select * from {{ source('public', 'raw_power') }}
),

retyped as (
    select
        -- ids
        cce_id,
        monitor_id,
        -- sensor reading
        CAST(power as INTEGER) as power, -- noqa: RF04
        -- time
        CAST(t as TIMESTAMP) as created_at,
        CAST(rt as TIMESTAMP) as received_at

    from source
)

select * from retyped
