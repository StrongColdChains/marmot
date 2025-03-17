SELECT *
FROM {{ ref('heat_fridge_alarms') }}
LIMIT 1