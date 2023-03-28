/*
 Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?
 */

WITH
philly_blockgroups AS (
    SELECT
        bg.geoid,
        bg.geog,
        bg.countyfp
    FROM census.blockgroups_2020 AS bg
    WHERE bg.countyfp = '42101'
),

septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        bg.geoid
    FROM septa.bus_stops AS stops
    INNER JOIN philly_blockgroups AS bg
        ON ST_DWithin(ST_SetSRID(stops.geog::geography, 4326), ST_SetSRID(bg.geog::geography, 4326), 800)
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop
        ON stops.geoid = pop.geoid
    GROUP BY stops.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops
    ON pop.stop_id = stops.stop_id
WHERE pop.estimated_pop_800m > 500
ORDER BY pop.estimated_pop_800m
LIMIT 8;

