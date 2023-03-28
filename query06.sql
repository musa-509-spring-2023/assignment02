/*
What are the top five neighborhoods according to your accessibility metric?

Both #6 and #7 should have the structure:

(
  neighborhood_name text,  -- The name of the neighborhood
  accessibility_metric ...,  -- Your accessibility metric value
  num_bus_stops_accessible integer,
  num_bus_stops_inaccessible integer
)
*/

-- join block groups to neighborhoods
with neighborhood_bgs as (
    select
        neighborhoods.mapname as neighborhood_name,
        neighborhoods.geog as n_geog,
        blockgroups_2020.geoid as geoid,
        blockgroups_2020.geog as bg_geoig
    from azavea.neighborhoods
    left join census.blockgroups_2020
        on st_within(st_centroid(st_setsrid(blockgroups_2020.geog::geometry, 2272)), st_setsrid(neighborhoods.geog::geometry, 2272))
),

-- trim geoid in census table
trim_geoid as (
    select
        p.total as population,
        substring(p.geoid from 10) as geoid
    from census.population_2020 as p
),

-- join census population figures to neighborhoods
neighborhood_pop as (
    select
        bgs.neighborhood_name,
        bgs.geoid,
        bgs.n_geog as geog,
        trim_geoid.geoid,
        sum(trim_geoid.population) as total_population
    from neighborhood_bgs as bgs
    left join trim_geoid
        on bgs.geoid = trim_geoid.geoid
    group by bgs.neighborhood_name, bgs.geoid, trim_geoid.geoid, geog
),

-- join stop info to neighborhoods
access_stops as (
    select
        stops.wheelchair_boarding,
        stops.geog,
        n.geog,
        n.neighborhood_name,
        n.total_population
    from septa.bus_stops as stops
    left join neighborhood_pop as n
        on st_within((st_setsrid(stops.geog::geometry, 2272)), st_setsrid(n.geog::geometry, 2272))
--where wheelchair_boarding = 1
),

-- aggregate stops by population for each neighborhood
aggregation as (
    select
        neighborhood_name,
        sum(total_population) as total_population,
        sum(wheelchair_boarding) as total_accessible_stops,
        abs(count(wheelchair_boarding) - sum(wheelchair_boarding)) as total_inaccessible_stops,
        round((sum(total_population) / sum(wheelchair_boarding))) as residents_per_accessible_stop
    from access_stops
    where total_population > 0
    group by neighborhood_name
)

select
    neighborhood_name::text,
    residents_per_accessible_stop as accessibility_metric,
    total_accessible_stops::integer as num_bus_stops_accessible,
    total_inaccessible_stops::integer as num_bus_stops_inaccessible
from aggregation
order by accessibility_metric asc
limit 5;
