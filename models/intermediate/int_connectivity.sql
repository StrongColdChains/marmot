-- Pull all the time series data for a base station
with unioned_ts as (
    select
        created_at,
        received_at,
        monitor_id,
        'door' as source
    from {{ ref('stg_door_ts') }}
    union distinct
    select
        created_at,
        received_at,
        monitor_id,
        'emd_connection' as source
    from {{ ref('stg_emd_connection_ts') }}
    union distinct
    select
        created_at,
        received_at,
        monitor_id,
        'power' as source
    from {{ ref('stg_power_ts') }}
    union distinct
    select
        created_at,
        received_at,
        monitor_id,
        'temperature' as source
    from {{ ref('stg_temperature_ts') }}
)

select
    created_at,
    received_at,
    monitor_id,
    received_at - created_at as lag,
    -- good lord, refactor this.
    case
        when
            (received_at - created_at)
            - interval '{{ var("connectivity_lateness_threshold") }} minutes'
            > interval '0 minutes'
            then
                (received_at - created_at)
                - interval '{{ var("connectivity_lateness_threshold") }} minutes'
        else interval '0 minutes'
    end
        as lateness,
    source
from unioned_ts
