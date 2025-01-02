with

source as (
    select * from {{ source('public', 'raw_temperature') }}
),

retyped as (
    select
        -- ids
        cce_id,
        monitor_id,
        -- sensor reading
        CAST(temperature as FLOAT) as temperature,
        -- time
        CAST(t as TIMESTAMP) as created_at,
        CAST(rt as TIMESTAMP) as received_at

    from source
)

select * from retyped
