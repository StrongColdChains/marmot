-- TODO: is it ok to have an intermediate table built off of mart tables?
-- NOTE: huh, I've never had to do something like this. Copied an approach from
-- https://medium.com/analytics-vidhya/sql-classic-problem-identifying-gaps-and-islands-across-overlapping-date-ranges-5681b5fcdb8 -- noqa: LT05
WITH ordered_intervals AS (
    SELECT
        cce_id,
        GREATEST(
            begin, '{{ var("now") }}'::timestamptz - INTERVAL '30 days'
        ) AS interval_begin,
        stop AS interval_stop
    FROM {{ ref('all_alarms') }}
    WHERE
        stop > '{{ var("now") }}'::timestamptz - INTERVAL '30 days'
    ORDER BY cce_id, interval_begin
),

overlapping AS (
    SELECT
        cce_id,
        interval_begin,
        interval_stop,
        ROW_NUMBER() OVER (
            ORDER BY cce_id, interval_begin, interval_stop
        ) AS rn,
        MAX(interval_stop)
            OVER (
                PARTITION BY cce_id
                ORDER BY
                    interval_begin, interval_stop
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            )
            AS previous_interval_stop
    FROM ordered_intervals
),

islands AS (
    SELECT
        *,
        -- this column is provided for debugging purposes, to make it clear
        -- when a new island has begun.
        CASE WHEN previous_interval_stop >= interval_begin THEN 0 ELSE 1 END
            AS is_new_island,
        SUM(CASE WHEN
            previous_interval_stop >= interval_begin THEN 0 ELSE 1 END)
            OVER (
                ORDER BY rn
            )
            AS island_id
    FROM overlapping
)

SELECT * FROM islands
