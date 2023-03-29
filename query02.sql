/*
Which eight bus stops have the smallest population above 500 people
inside of Philadelphia within 800 meters of the stop (Philadelphia
county block groups have a geoid prefix of 42101 -- that's 42 for the
state of PA, and 101 for Philadelphia county)?
*/

SELECT bs.stop_id, ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326) AS stop_geog, SUM(population) AS total_population
FROM septa.bus_stops AS bs
JOIN census.blockgroups_2020 AS bg ON ST_DWithin(ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326)::geography, bg.geom::geography, 800)
JOIN census.population_2020 AS pop ON bg.geoid = pop.blockgroup_id
WHERE bg.geoid LIKE '42101%'
GROUP BY bs.stop_id, stop_geog
HAVING SUM(population) > 500
ORDER BY total_population
LIMIT 8

