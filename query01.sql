/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

with

septa_bus_stop_blockgroups as (
    select
        septa.bus_stops.stop_id,
        '1500000US' || census.blockgroups_2020.geoid as geoid
    from septa.bus_stops
    inner join census.blockgroups_2020
        on
            st_dwithin(
                st_setsrid(septa.bus_stops.geog, 4326),
                st_setsrid(census.blockgroups_2020.geog, 4326),
                800
            )
),

septa_bus_stop_surrounding_population as (
    select
        septa_bus_stop_blockgroups.stop_id,
        sum(census.population_2020.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups
    inner join
        census.population_2020 on
            septa_bus_stop_blockgroups.geoid = population_2020.geoid
group by septa_bus_stop_blockgroups.stop_id -- noqa: L003
)

select
    septa.bus_stops.stop_name,
    septa_bus_stop_surrounding_population.estimated_pop_800m,
    septa.bus_stops.geog
from septa_bus_stop_surrounding_population
inner join
    septa.bus_stops on
        septa_bus_stop_surrounding_population.stop_id = bus_stops.stop_id
order by septa_bus_stop_surrounding_population.estimated_pop_800m desc
limit 8
