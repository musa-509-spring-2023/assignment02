/*
You're tasked with giving more contextual information to rail stops to
fill the stop_desc field in a GTFS feed. Using any of the data sets above,
PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL
string functions, build a description (alias as stop_desc) for each stop.
Feel free to supplement with other datasets (must provide link to data used
so it's reproducible), and other methods of describing the relationships.
SQL's CASE statements may be helpful for some operations.
*/



SELECT
    stops.stop_id,
    stops.stop_name,
    stops.stop_lon,
    stops.stop_lat
    CONCAT('Located in ', REPLACE(LOWER(nhoods.name), '_', ' '), ' neighborhood') AS stop_desc,	
FROM septa.bus_stops AS stops
INNER JOIN azavea.neighborhoods AS nhoods
    ON ST_INTERSECTS(nhoods.geog, stops.geog::geography)
