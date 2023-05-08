/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. 
Using any of the data sets above, 
PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), 
and PostgreSQL string functions, 
build a description (alias as `stop_desc`) for each stop. 
Feel free to supplement with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.
*/

/*
Columns in the septa.rail_stops
stop_id
stop_name
stop_desc wait to fill this column
stop_lat
stop_lon
zone_id
stop_url no data in this column
geog

caculate the population within 800m of each station and update the table
*/
WITH 

septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.rail_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)

UPDATE septa.rail_stops AS stops
SET stop_desc = CAST(pop.estimated_pop_800m AS INT)
FROM septa_bus_stop_surrounding_population AS pop
WHERE stops.stop_id = pop.stop_id;

SELECT *
FROM septa.rail_stops
ORDER BY septa.rail_stops.stop_desc DESC;

