CREATE INDEX bus_routes_geog_idx ON phl.pwd_parcels USING gist (geog);
CREATE INDEX bus_stops_geog_idx ON septa.bus_stops USING gist (geog);

WITH
the_route AS (
    SELECT
        shapes.shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(
            ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326
        )
        ORDER BY shapes.shape_pt_sequence)) AS shape_geog
    FROM septa.bus_shapes AS shapes
    GROUP BY shapes.shape_id
),

route_length AS (
    SELECT
        the_route.shape_id,
        the_route.shape_geog,
        ST_LENGTH(the_route.shape_geog::geography) AS shape_length
    FROM the_route
	GROUP BY shape_id, shape_geog
),

final_table AS (
    SELECT
        route_length.shape_id,
        route_length.shape_length,
        trips.trip_headsign,
        route_length.shape_geog,
        trips.route_id
    FROM route_length
    INNER JOIN septa.bus_trips AS trips USING (shape_id)
)

SELECT DISTINCT
    routes.route_short_name,
    final_table.trip_headsign,
    final_table.shape_geog,
    final_table.shape_length
FROM septa.bus_routes AS routes 
INNER JOIN final_table 
	ON final_table.route_id = routes.route_id
ORDER BY shape_length DESC
LIMIT 2
