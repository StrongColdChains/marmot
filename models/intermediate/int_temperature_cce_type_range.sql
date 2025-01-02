SELECT
    *,
    CASE
        WHEN temperature < -40 THEN 'invalid_low'
        WHEN temperature < -5 THEN 'freezer'
        WHEN temperature < 12 THEN 'fridge'
        WHEN temperature < 40 THEN 'ambient'
        ELSE 'invalid_high'
    END AS temperature_cce_type_range
FROM {{ ref('stg_temperature_ts') }}
