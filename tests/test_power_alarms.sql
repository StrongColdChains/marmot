WITH expected_results AS (
    SELECT TIMESTAMP '2023-11-20 10:00:00' AS begin, 
           TIMESTAMP '2023-11-21 10:00:01' AS stop, 
           'a' AS cce_id
    UNION ALL
    SELECT TIMESTAMP '2023-11-22 00:00:00', 
           CAST(NULL AS TIMESTAMP), 
           'a'
)

SELECT 
    actual.begin, 
    actual.stop, 
    actual.cce_id
FROM {{ ref('power_alarms') }} AS actual
FULL OUTER JOIN expected_results AS expected
ON actual.begin = expected.begin 
AND actual.stop IS NOT DISTINCT FROM expected.stop 
AND actual.cce_id = expected.cce_id
WHERE actual.begin IS NULL OR expected.begin IS NULL