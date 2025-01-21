with heat_alarms as (
    select *
    from {{ ref('heat_freezer_alarms') }}
    where stop > '{{ var("now") }}'::timestamptz - interval '30 days'
    union all
    select *
    from {{ ref('heat_fridge_alarms') }}
    where stop > '{{ var("now") }}'::timestamptz - interval '30 days'
),

freeze_alarms as (
    select *
    from {{ ref('freeze_fridge_alarms') }}
    where stop > '{{ var("now") }}'::timestamptz - interval '30 days'
),

nonfunctional_cces as (
    select cce_id
    from heat_alarms
    group by cce_id
    having COUNT(*) >= 5
    union distinct
    select cce_id
    from heat_alarms
    where duration > interval '48 hours'
    group by cce_id
    union distinct
    select cce_id
    from freeze_alarms
    group by cce_id
)

-- TODO: It is very bad practice to not have the intermediate
-- calculations used in determining functional status not easily
-- viewable somewhere. Let's fix this.
select
    cce_id,
    '0' as functional_status
from nonfunctional_cces
union distinct
select
    cce_id,
    '1' as functional_status
from {{ ref('int_all_cces') }}
where cce_id not in (select nonfunctional_cces.cce_id from nonfunctional_cces)
