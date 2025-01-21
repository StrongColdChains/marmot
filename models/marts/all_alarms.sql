select
    *,
    'door' as alarm_type
from {{ ref('door_alarms') }}
union distinct
select
    *,
    'power' as alarm_type
from {{ ref('power_alarms') }}
union distinct
select
    *,
    'heat_fridge' as alarm_type
from {{ ref('heat_fridge_alarms') }}
union distinct
select
    *,
    'heat_freezer' as alarm_type
from {{ ref('heat_freezer_alarms') }}
union distinct
select
    *,
    'freeze_fridge' as alarm_type
from {{ ref('freeze_fridge_alarms') }}
union distinct
select
    *,
    'emd_connection' as alarm_type
from {{ ref('emd_connection_alarms') }}
