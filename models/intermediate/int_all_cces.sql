-- Pull all cce_ids from our source tables.
select cce_id
from {{ ref('stg_door_ts') }}
union distinct
select cce_id
from {{ ref('stg_emd_connection_ts') }}
union distinct
select cce_id
from {{ ref('stg_power_ts') }}
union distinct
select cce_id
from {{ ref('stg_temperature_ts') }}
