/*
 Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?
 */


WITH

 -- bus stop inside philly

bus_stop_philly as (SELECT b.*
FROM septa.bus_stops AS b
JOIN azavea.neighborhoods AS n
ON ST_Within(b.geog::geometry, n.geog::geometry)
),

 -- join censusblock with population on geoid

census_block_pop as (

SELECT blocks.geoid, pops.total, blocks.geog
FROM census.blockgroups_2020 as blocks
INNER JOIN census.population_2020 as pops using (geoid)

),

 -- censusblock whitin 800m

bus_stops_800_pop as (
SELECT b.stop_id, sum(p.total) as estimated_pop_800m
FROM bus_stop_philly AS b
JOIN census_block_pop AS p
ON ST_dWithin(b.geog::geometry, p.geog::geometry, 0.008)
GROUP BY b.stop_id
)

 -- select smalest above 500

SELECT pop.stop_id, pop.estimated_pop_800m, stops.geog
FROM bus_stops_800_pop AS pop
INNER JOIN bus_stop_philly AS stops using(stop_id)
WHERE estimated_pop_800m > 500
ORDER BY estimated_pop_800m
LIMIT 8

