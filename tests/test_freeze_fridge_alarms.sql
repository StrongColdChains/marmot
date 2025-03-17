WITH expected_results AS (
    SELECT TIMESTAMP '2023-11-22 02:00:00' AS begin, 
           TIMESTAMP '2023-11-22 04:00:00' AS stop, 
           'a' AS cce_id
    UNION ALL
    SELECT TIMESTAMP '2023-11-22 04:30:00', 
           CAST(NULL AS TIMESTAMP), 
           'a'
    UNION ALL
    SELECT TIMESTAMP '2023-11-22 02:00:00', 
           TIMESTAMP '2023-11-22 04:00:00', 
           'b'
)
SELECT actual.*
FROM {{ ref('freeze_fridge_alarms') }} actual
LEFT JOIN expected_results expected 
ON actual.begin = expected.begin
AND actual.stop IS NOT DISTINCT FROM expected.stop
AND actual.cce_id = expected.cce_id
WHERE expected.begin IS NULL

/*
WITH expected_results AS (
    SELECT TIMESTAMP '2023-11-22 02:00:00' AS begin, 
           TIMESTAMP '2023-11-22 04:00:00' AS stop, 
           'a' AS cce_id
    UNION ALL
    SELECT TIMESTAMP '2023-11-22 04:30:00', 
           CAST(NULL AS TIMESTAMP), 
           'a'
    UNION ALL
    SELECT TIMESTAMP '2023-11-22 02:00:00', 
           TIMESTAMP '2023-11-22 04:00:00', 
           'b'
)
SELECT actual.*
FROM public.freeze_fridge_alarms actual
LEFT JOIN expected_results expected 
ON actual.begin = expected.begin
AND actual.stop IS NOT DISTINCT FROM expected.stop
AND actual.cce_id = expected.cce_id
WHERE expected.begin IS NULL
*/