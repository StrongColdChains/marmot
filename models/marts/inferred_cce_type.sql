WITH ranked_data AS (
    SELECT
        cce_id,
        temperature_cce_type_range,
        RANK() OVER (
            PARTITION BY cce_id
            ORDER BY
                CASE
                    WHEN temperature_cce_type_range = 'invalid_high' THEN 1
                    WHEN temperature_cce_type_range = 'invalid_low' THEN 2
                    ELSE 3
                END,
                COUNT(*) DESC
        ) AS cce_type_rank
    FROM {{ ref('int_temperature_cce_type_range') }}
    WHERE created_at >= '{{ var("now") }}'::timestamptz - INTERVAL '30 days'
    GROUP BY cce_id, temperature_cce_type_range
)

SELECT
    cce_id,
    temperature_cce_type_range AS inferred_cce_type
FROM ranked_data
WHERE cce_type_rank = 1
