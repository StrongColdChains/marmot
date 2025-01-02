with

source as (
    select * from {{ source('public', 'raw_emd_connection') }}
),

retyped as (
    select
        -- ids
        cce_id,
        monitor_id,
        -- sensor reading
        CAST(connected as INTEGER) as connected,
        -- time
        CAST(t as TIMESTAMP) as created_at,
        CAST(rt as TIMESTAMP) as received_at

    from source
)

select * from retyped
