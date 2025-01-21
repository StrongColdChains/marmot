select
    *,
    'door' as alarm_type
from {{ ref('door_alarms') }}
union
select
    *,
    'power' as alarm_type
from {{ ref('power_alarms') }}
union
select
    *,
    'heat_fridge' as alarm_type
from {{ ref('heat_fridge_alarms') }}
union
select
    *,
    'heat_freezer' as alarm_type
from {{ ref('heat_freezer_alarms') }}
union
select
    *,
    'freeze_fridge' as alarm_type
from {{ ref('freeze_fridge_alarms') }}
union
select
    *,
    'emd_connection' as alarm_type
from {{ ref('emd_connection_alarms') }}
