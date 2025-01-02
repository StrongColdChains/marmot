WITH input_with_lag AS (
    SELECT
        temperature,
        -- TODO: / NOTE: should we even care about monitor ID here?
        -- if alarms are keyed on CCE, then we shouldn't care about
        -- the device that's monitoring that CCE.
        cce_id,
        monitor_id,
        CAST(created_at AS TIMESTAMP) AS created_at,
        LAG(CAST(created_at AS TIMESTAMP))
            OVER (
                PARTITION BY (cce_id, monitor_id)
                ORDER BY CAST(created_at AS TIMESTAMP)
            )
            AS previous_created_at
    FROM {{ ref('stg_temperature_ts') }}
),

threshold_crossed AS (
    SELECT
        temperature,
        created_at,
        cce_id,
        monitor_id,
        {% for alarm_dict in var("defined_temperature_alarms") %}
            CASE
                WHEN
                    -- compares temperature to the threshold using the
                    -- comparison operator defined for this alarm.
                    temperature
                    {{ alarm_dict['comparison_operator'] }}
                    {{ alarm_dict['threshold'] }}
                    THEN TRUE ELSE
                    FALSE
            END
                AS {{ alarm_dict['alarm_name'] }}_threshold_is_crossed,
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
        {% for alarm_dict in var("defined_temperature_alarms") %}
            SUM(
                CASE
                    WHEN
                        {{ alarm_dict['alarm_name'] }}_threshold_is_crossed
                        = FALSE
                        THEN 1 ELSE
                        0
                END
            )
                OVER (
                    PARTITION BY (cce_id, monitor_id)
                    ORDER BY created_at
                )
                AS {{ alarm_dict['alarm_name'] }}_reset_group,
        {% endfor %}
        *
    FROM threshold_crossed
),

cumulative_threshold_crossed AS (
    SELECT
        {% for alarm_dict in var("defined_temperature_alarms") %}
            {{ alarm_dict['alarm_name'] }}_threshold_is_crossed,
            {{ alarm_dict['alarm_name'] }}_reset_group,
            SUM(
                CASE
                    WHEN
                        {{ alarm_dict['alarm_name'] }}_threshold_is_crossed
                        = TRUE
                        {# THEN COALESCE(minutes_since_previous_datapoint, 0) #}
                        THEN minutes_since_previous_datapoint
                    ELSE 0
                END
            )
                OVER (
                    PARTITION BY
                        (
                            {{ alarm_dict['alarm_name'] }}_reset_group,
                            cce_id,
                            monitor_id
                        )
                    ORDER BY created_at
                )
                AS {{ alarm_dict['alarm_name'] }}_cumulative_threshold_minutes,
        {% endfor %}
        created_at,
        temperature,
        minutes_since_previous_datapoint,
        cce_id,
        monitor_id
    FROM reset_groups
),

freeze_intervals AS (
    SELECT
        -- Identify when the freeze alarm begins or stops
        {% for alarm_dict in var("defined_temperature_alarms") %}
            CASE
            -- begin: Cumulative time below 0°C exceeds 60 minutes
            -- NOTE: by specifying > rather than >= here, excursions that last
            -- *exactly* 60 minutes do not count as a freeze alarm.
                WHEN
                    {{ alarm_dict['alarm_name'] }}_cumulative_threshold_minutes
                    > 60
                    AND LAG(
                        {{ alarm_dict['alarm_name'] }}_cumulative_threshold_minutes
                    )
                        OVER (
                            PARTITION BY (cce_id, monitor_id)
                            ORDER BY created_at
                        )
                    <= 60
                    THEN 'begin'
                WHEN
                    LAG(
                        {{ alarm_dict['alarm_name'] }}_cumulative_threshold_minutes
                    )
                        OVER (
                            PARTITION BY (cce_id, monitor_id)
                            ORDER BY created_at
                        )
                    > 60
                    THEN
                        CASE
                            -- ongoing: in an alarm state
                            WHEN
                                {{ alarm_dict['alarm_name'] }}_threshold_is_crossed
                                = TRUE
                                THEN 'ongoing'
                            -- stop: Previously in an alarm state and 
                            -- temperature rises above 0
                            ELSE 'stop'
                        END
                ELSE 'no_freeze_alarm'
            END AS {{ alarm_dict['alarm_name'] }}_freeze_status,
        {% endfor %}
        *
    FROM cumulative_threshold_crossed
)

SELECT *
FROM freeze_intervals
