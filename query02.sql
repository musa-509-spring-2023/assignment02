with
ph_bg as (
    select *
    from census.blockgroups_2020
    where statefp = '42' and countyfp = '101'
),


septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        '1500000US' || ph_bg.geoid as geoid
    from septa.bus_stops as stops
    inner join ph_bg
        on st_dwithin(stops.geog, st_setsrid(ph_bg.geog::geography, 4326), 800)
),

septa_bus_stop_surrounding_population as (
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
)

select
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
where pop.estimated_pop_800m >= 500
order by pop.estimated_pop_800m
limit 8
