{% macro threshold_detection(
    source_table, 
    time_column, 
    float_column, 
    comparison_operator,
    threshold,
    duration_threshold
) %}
WITH input_with_lag AS (
    SELECT
        {{ float_column }} AS metric_value,
        {{ time_column }} AS created_at,
        cce_id,
        LAG({{ time_column }})
            OVER (
                PARTITION BY cce_id
                ORDER BY {{ time_column }}
            ) AS previous_created_at,
        LAG({{ float_column }})
            OVER (
                PARTITION BY cce_id
                ORDER BY {{ time_column }}
            ) AS previous_metric_value
    FROM {{ source_table }}
),

threshold_crossed AS (
    SELECT
        metric_value,
        created_at,
        cce_id,
        CASE
            WHEN
                metric_value
                {{ comparison_operator }}
                {{ threshold }}
            THEN TRUE ELSE
            FALSE
        END AS threshold_is_crossed,
        CASE
            WHEN
                previous_metric_value
                {{ comparison_operator }}
                {{ threshold }}
            THEN TRUE ELSE
            FALSE
        END AS previous_threshold_is_crossed,
        -- Calculate the time difference from the previous row in minutes
        EXTRACT(epoch FROM (created_at - previous_created_at))
        / 60.0 AS minutes_since_previous_datapoint
    FROM input_with_lag
),

-- Whenever the threshold is no longer crossed, we need to reset the cumulative
-- time counter. reset_group is a way to track when the counter needs to be
-- reset.
reset_groups AS (
    SELECT
        -- reset_group will be used with PARTITION BY to ensure we reset
        -- cumulative time properly.
        SUM(
            CASE
                -- When we have started a new threshold, increment reset_group
                WHEN
                    threshold_is_crossed = TRUE
                    and
                    previous_threshold_is_crossed = FALSE
                THEN 1
                ELSE 0
            END
        ) OVER (
            PARTITION BY cce_id
            ORDER BY created_at
        ) AS reset_group,
        *
    FROM threshold_crossed
),

cumulative_threshold_crossed AS (
    SELECT
        threshold_is_crossed,
        reset_group,
        SUM(
            CASE
                WHEN COALESCE(previous_threshold_is_crossed, FALSE) = TRUE
                THEN COALESCE(minutes_since_previous_datapoint, 0)
                ELSE 0
            END
        ) OVER (
            PARTITION BY reset_group, cce_id
            ORDER BY created_at
        ) AS cumulative_minutes,
        created_at,
        metric_value,
        minutes_since_previous_datapoint,
        cce_id
    FROM reset_groups
)

SELECT * FROM cumulative_threshold_crossed
{% endmacro %}
