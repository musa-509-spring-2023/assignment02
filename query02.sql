/*
Which eight bus stops have the smallest population above 500 people
inside of Philadelphia within 800 meters of the stop
(Philadelphia county block groups have a geoid prefix of 42101 --
that's 42 for the state of PA, and 101 for Philadelphia county)?
*/
--explain
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

-- blockgroups within 800m of a septa stop
philly_blockgroups_within_800m as (
    select
        stops.stop_id as stop_id,
        stops.stop_name as stop_name,
        stops.geog as geog,
        '1500000US' || phl_bg.geoid as geoid
    from septa.bus_stops as stops
    inner join philly_blockgroups as phl_bg
        on st_dwithin(stops.geog, st_setsrid(phl_bg.geog::geography, 4326), 800)
),

-- join population to block group
philly_pop as (
    select
        p.stop_name,
        p.geog,
        sum(c.total) as total_pop
    from philly_blockgroups_within_800m as p
    left join census.population_2020 as c
        on p.geoid = c.geoid
    group by stop_name, geog
    order by total_pop desc
)


select
    philly_pop.stop_name::text as stop_name,
    philly_pop.total_pop::int as estimated_pop_800m,
    philly_pop.geog as geog
from philly_pop
where philly_pop.total_pop > 500
order by philly_pop.total_pop
limit 8;
