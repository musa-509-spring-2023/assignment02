WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid,
        bg.statefp AS statefp,
        bg.countyfp AS countyfp
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(ST_SetSRID(stops.geog::geography, 4326), ST_SetSRID(bg.geog::geography, 4326), 800)
    WHERE bg.statefp::INTEGER = 42 AND bg.countyfp::INTEGER = 101
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)
SELECT
    stops.stop_name,
    stops.geog,
    pop.estimated_pop_800m
FROM septa.bus_stops AS stops
INNER JOIN septa_bus_stop_surrounding_population AS pop USING (stop_id)
WHERE pop.estimated_pop_800m >= 500
ORDER BY pop.estimated_pop_800m ASC
LIMIT 8;