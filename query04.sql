WITH bus_length AS (
    SELECT
        shapes.shape_id AS shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326) ORDER BY shapes.shape_pt_sequence)) AS shape_geog,
        ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326) ORDER BY shapes.shape_pt_sequence))) AS shape_length
    FROM septa.bus_shapes AS shapes
    GROUP BY shapes.shape_id
),

trips AS (
    SELECT
        bus_trips.trip_headsign,
        bus_trips.shape_id,
	    bus_trips.route_id,
        bus_length.shape_length,
        bus_length.shape_geog,
        bus_length.shape_id
    FROM bus_length
    JOIN septa.bus_trips
        ON (bus_length.shape_id = bus_trips.shape_id)
),

lastt AS (
    SELECT
        routes.route_short_name,
        trips.trip_headsign,
        trips.shape_length,
        trips.shape_geog,
        trips.route_id
    FROM trips
    JOIN septa.bus_routes AS routes
        ON (trips.route_id = routes.route_id)
)

SELECT DISTINCT
    lastt.route_short_name,
    lastt.trip_headsign,
    lastt.shape_length,
    lastt.shape_geog
FROM lastt
ORDER BY lastt.shape_length DESC
LIMIT 2
