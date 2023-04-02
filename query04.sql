WITH shape AS (
    SELECT
        shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) ORDER BY shape_pt_sequence))::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

length AS (
    SELECT
        *,
        ST_LENGTH(shape_geog) AS shape_length
    FROM shape
)

SELECT DISTINCT
    trips.trip_headsign,
    routes.route_short_name,
    length.shape_geog,
    length.shape_length
FROM shape
INNER JOIN septa.bus_trips AS trips ON shape.shape_id = trips.shape_id
INNER JOIN septa.bus_routes AS routes ON routes.route_id = trips.route_id
INNER JOIN length ON length.shape_id = shape.shape_id
ORDER BY length.shape_length DESC
LIMIT 2
