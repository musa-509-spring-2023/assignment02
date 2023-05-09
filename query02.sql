with
stops_bg as (
    select
        septa.bus_stops.stop_name,
        census.blockgroups_2020.geoid,
        septa.bus_stops.geog
    from septa.bus_stops
    inner join census.blockgroups_2020
        on st_dwithin(
            st_setsrid(septa.bus_stops.geog::geography, 4326),
            st_setsrid(census.blockgroups_2020.geog::geography, 4326), 800
            )
),

pop as (
    select
        total,
        substring(geoid from 10) as geoid
    from census.population_2020
    where geoid like '1500000US42101%'
),

stops_pop as (
    select
        stops_bg.stop_name,
        stops_bg.geog,
        sum(pop.total) as estimated_pop_800m
    from
        stops_bg
    inner join
        pop on (geoid) -- noqa: L027
    group by stops_bg.stop_name, stops_bg.geog
)

select
    stop_name,
    estimated_pop_800m,
    geog
from stops_pop
where estimated_pop_800m > 500
order by estimated_pop_800m
limit 8;
