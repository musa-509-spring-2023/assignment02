CREATE INDEX bus_routes_geog_idx ON phl.pwd_parcels USING gist (geog);
CREATE INDEX bus_stops_geog_idx ON septa.bus_stops USING gist (geog);



WITH trip_info AS (
    SELECT
        bus.route_id AS bus_route_id,
        trips.route_id AS trips_route_id,
        bus.route_short_name,
        trips.trip_headsign,
        trips.shape_id
    FROM septa.bus_routes AS bus
    JOIN septa.bus_trips AS trips USING (route_id)
)

SELECT
    trip_info.route_short_name,
    trip_info.trip_headsign,
    shapes.shape_id,
    ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326) ORDER BY shapes.shape_pt_sequence)) AS shape_geog,
    ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326) ORDER BY shapes.shape_pt_sequence))) AS shape_length
FROM septa.bus_shapes AS shapes
LEFT JOIN trip_info ON trip_info.shape_id = shapes.shape_id
GROUP BY shapes.shape_id, trip_info.route_short_name, trip_info.trip_headsign
ORDER BY shape_length DESC
LIMIT 2
