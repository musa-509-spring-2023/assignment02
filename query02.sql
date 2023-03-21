/*
Which eight bus stops have the smallest population above 500 people
inside of Philadelphia within 800 meters of the stop
(Philadelphia county block groups have a geoid prefix of 42101 --
that's 42 for the state of PA, and 101 for Philadelphia county)?
*/

with

-- block groups in Philly
philly_blockgroups as (
    select
        geoid,
        geog,
        statefp,
        countyfp
    from census.blockgroups_2020 as bg
    where
        bg.statefp::int = 042 and bg.countyfp::int = 101

),

-- philly blockgroups within 800 meters of septa stops
philly_septa_stops as (
    select
        stops.stop_id as stop_id,
        stops.stop_name as stop_name,
        stops.geog as geog,
        '1500000US' || phl_bg.geoid as geoid
    from septa.bus_stops as stops
    inner join philly_blockgroups as phl_bg
        on st_dwithin(st_setsrid(stops.geog::geography, 4326), st_setsrid(phl_bg.geog::geography, 4326), 800)
),

-- philly blockgroups within 800 meters of septa stops, with population
philly_pop as (
    select *
    from philly_septa_stops
    left join census.population_2020
        on philly_septa_stops.geoid = population_2020.geoid
)

select
    philly_pop.stop_name::text as stop_name,
    philly_pop.total::int as estimated_pop_800m,
    philly_pop.geog as geog
from philly_pop
where philly_pop.total > 500
order by philly_pop.total
limit 8;
