/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

-- Note to self: I ran lines 34-38 in db_structure and removed the st_makepoint from the code

WITH
septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        stops.geog,
        '1500000US' || bg."GEOID" AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON st_dwithin(stops.geog, bg.geog, 800)
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        sum(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
ORDER BY pop.estimated_pop_800m DESC, stops.geog DESC
LIMIT 8
