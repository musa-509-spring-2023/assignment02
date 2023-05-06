/*Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
find the two routes with the longest trips.*/
WITH lengths AS (
    SELECT
        s.shape_id AS shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(s.shape_pt_lon, s.shape_pt_lat), 4326) ORDER BY s.shape_pt_sequence)) AS shape_geog,
        ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(s.shape_pt_lon, s.shape_pt_lat), 4326) ORDER BY s.shape_pt_sequence))) AS shape_length
    FROM septa.bus_shapes AS s
    GROUP BY s.shape_id
)

SELECT DISTINCT
    r.route_short_name,
    t.trip_headsign,
    l.shape_length,
    l.shape_geog
FROM lengths AS l
INNER JOIN septa.bus_trips AS t ON l.shape_id = t.shape_id
INNER JOIN septa.bus_routes AS r ON t.route_id = r.route_id
ORDER BY l.shape_length DESC
LIMIT 2;
