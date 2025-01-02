{% macro alarm_detection(
    source_table, 
    time_column, 
    float_column, 
    partition_columns, 
    defined_alarms
) %}
WITH input_with_lag AS (
    SELECT
        {{ float_column }} AS metric_value,
        {{ time_column }} AS created_at,
        -- TODO: / NOTE: should we even care about monitor ID here?
        -- if alarms are keyed on CCE, then we shouldn't care about
        -- the device that's monitoring that CCE.
        {% for column in partition_columns %}
            {{ column }},
        {% endfor %}
        LAG({{ time_column }})
            OVER (
                PARTITION BY 
                    {% for column in partition_columns %}
                        {{ column }}{{ "," if not loop.last else "" }}
                    {% endfor %}
                ORDER BY {{ time_column }}
            ) AS previous_created_at
    FROM {{ source_table }}
),

threshold_crossed AS (
    SELECT
        metric_value,
        created_at,
        {% for column in partition_columns %}
            {{ column }},
        {% endfor %}
        {% for alarm_dict in defined_alarms %}
            CASE
                WHEN
                    metric_value
                    {{ alarm_dict['comparison_operator'] }}
                    {{ alarm_dict['threshold'] }}
                THEN TRUE ELSE
                FALSE
            END AS threshold_is_crossed,
        {% endfor %}
        -- Calculate the time difference from the previous row in minutes
        EXTRACT(epoch FROM (created_at - previous_created_at))
        / 60 AS minutes_since_previous_datapoint
    FROM input_with_lag
),

-- Whenever the threshold is no longer crossed, we need to reset the cumulative
-- time counter. reset_group is a way to track when the counter needs to be
-- reset.
reset_groups AS (
    SELECT
        -- reset_group will be used with PARTITION BY to ensure we reset
        -- cumulative time properly.
        {% for alarm_dict in defined_alarms %}
            SUM(
                CASE
                    WHEN
                        threshold_is_crossed
                        = FALSE
                        THEN 1 ELSE
                        0
                END
            ) OVER (
                PARTITION BY 
                    {% for column in partition_columns %}
                        {{ column }}{{ "," if not loop.last else "" }}
                    {% endfor %}
                ORDER BY created_at
            ) AS reset_group,
        {% endfor %}
        *
    FROM threshold_crossed
),

cumulative_threshold_crossed AS (
    SELECT
        {% for alarm_dict in defined_alarms %}
            threshold_is_crossed,
            reset_group,
            SUM(
                CASE
                    WHEN threshold_is_crossed
                    = TRUE
                    -- TODO: do we need this coalesce? how is the
                    -- first datapoint handled if coalesce disappears?
                    THEN COALESCE(minutes_since_previous_datapoint, 0)
                    ELSE 0
                END
            ) OVER (
                PARTITION BY reset_group,
                    {% for column in partition_columns %}
                        {{ column }}{{ "," if not loop.last else "" }}
                    {% endfor %}
                ORDER BY created_at
            ) AS cumulative_minutes,
        {% endfor %}
        created_at,
        metric_value,
        minutes_since_previous_datapoint,
        {% for column in partition_columns %}
            {{ column }}{{ "," if not loop.last else "" }}
        {% endfor %}
    FROM reset_groups
),

intervals AS (
    SELECT
        -- Identify when the alarm begins or stops
        {% for alarm_dict in defined_alarms %}
            CASE
            -- begin: Cumulative time below 0°C exceeds 60 minutes
            -- NOTE: by specifying > rather than >= for your
            -- comparison_operator, excursions that last
            -- *exactly* duration_threshold do not count as an alarm.
                WHEN
                    cumulative_minutes
                    > {{ alarm_dict['duration_threshold'] }}
                    AND LAG(
                        cumulative_minutes
                        )
                        OVER (
                            PARTITION BY
                            {% for column in partition_columns %}
                                {{ column }}{{ "," if not loop.last else "" }}
                            {% endfor %}
                            ORDER BY created_at
                        ) <= {{ alarm_dict['duration_threshold'] }}
                    THEN 'begin'
                WHEN LAG(cumulative_minutes)
                        OVER (
                            PARTITION BY
                            {% for column in partition_columns %}
                                {{ column }}{{ "," if not loop.last else "" }}
                            {% endfor %}
                            ORDER BY created_at
                        ) > {{ alarm_dict['duration_threshold'] }}
                    THEN
                        CASE
                            WHEN
                                threshold_is_crossed
                                = TRUE THEN 'ongoing'
                            ELSE 'stop'
                        END
                ELSE 'no_alarm'
            END AS alarm_status,
        {% endfor %}
        *
    FROM cumulative_threshold_crossed
)

SELECT *
FROM intervals
{% endmacro %}
