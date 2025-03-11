with

source as (
    select * from {{ source('public', 'raw_ack') }}
),

retyped as (
    select
        cce_id,
        CAST(t as TIMESTAMP) as created_at,
        CAST(rt as TIMESTAMP) as received_at

    from source
)

select * from retyped