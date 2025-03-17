WITH expected_results AS (
    SELECT TIMESTAMP '2023-11-21 00:10:00' AS begin, 
           TIMESTAMP '2023-11-21 00:40:00' AS stop, 
           'a' AS cce_id
    UNION ALL
    SELECT TIMESTAMP '2023-11-21 01:00:00', 
           TIMESTAMP '2023-11-21 01:31:00', 
           'a'
)

SELECT 
    actual.begin, 
    actual.stop, 
    actual.cce_id
FROM {{ ref('emd_connection_alarms') }} AS actual
FULL OUTER JOIN expected_results AS expected
ON actual.begin = expected.begin 
AND actual.stop IS NOT DISTINCT FROM expected.stop 
AND actual.cce_id = expected.cce_id
WHERE actual.begin IS NULL OR expected.begin IS NULL