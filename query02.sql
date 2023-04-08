-- Calculate estimated population within 800 meters of SEPTA bus stops in Philadelphia,
-- filtering only stops with more than 500 people within 800 meters.
WITH septa_stops_blockgroups AS (
    -- Find all block groups within 800 meters of each bus stop
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS blockgroup_id
    FROM
        septa.bus_stops AS stops
        INNER JOIN census.blockgroups_2020 AS bg ON ST_DWithin(
            ST_SetSRID(stops.geog::geography, 4326),
            ST_SetSRID(bg.geog::geography, 4326),
            800
        )
),
septa_stops_population AS (
    -- Calculate estimated population within 800 meters of each bus stop
    SELECT
        stops.stop_id,
        SUM(population.total) AS estimated_population
    FROM
        septa_stops_blockgroups AS stops
        INNER JOIN census.population_2020 AS population ON stops.blockgroup_id = population.geoid
    GROUP BY
        stops.stop_id
)
-- Retrieve the stop name, geographic location, and estimated population for stops with more than 500 people within 800 meters,
-- sorted by estimated population in ascending order, and limited to the top 8 stops.
SELECT
    stops.stop_name,
    population.estimated_population AS estimated_pop_800m,
    stops.geog AS Geog
FROM
    septa_stops_population AS population
    INNER JOIN septa.bus_stops AS stops ON population.stop_id = stops.stop_id
WHERE
    estimated_pop_800m > 500
ORDER BY
    estimated_pop_800m ASC
LIMIT 8;
