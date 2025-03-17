WITH expected_results AS (
    SELECT TIMESTAMP '2023-11-21 00:04:00' AS begin, 
           TIMESTAMP '2023-11-21 00:09:00' AS stop, 
           'a' AS cce_id
    UNION ALL
    SELECT TIMESTAMP '2023-11-21 00:10:00', 
           TIMESTAMP '2023-11-21 00:16:00', 
           'a'
    -- Verify time series data that isn't even in spacing still results in alarms
    UNION ALL
    SELECT TIMESTAMP '2023-11-21 00:02:00', 
           CAST(NULL AS TIMESTAMP),
           'b'
    UNION ALL
    SELECT TIMESTAMP '2023-11-21 00:02:00', 
           CAST(NULL AS TIMESTAMP),
           'c'
)

SELECT 
    actual.begin, 
    actual.stop, 
    actual.cce_id
FROM {{ ref('door_alarms') }} AS actual
FULL OUTER JOIN expected_results AS expected
ON actual.begin = expected.begin 
AND actual.stop IS NOT DISTINCT FROM expected.stop 
AND actual.cce_id = expected.cce_id
WHERE actual.begin IS NULL OR expected.begin IS NULL