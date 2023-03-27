/* Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
find the two routes with the longest trips. */

WITH
bus_routes AS (
    SELECT
        routes.route_short_name,
        trips.trip_headsign,
        trips.shape_id
    FROM septa.bus_routes AS routes INNER JOIN septa.bus_trips AS trips ON routes.route_id = trips.route_id
),

bus_geo AS (
    SELECT
        shape.shape_id,
        st_makeline(array_agg(st_setsrid(st_makepoint(shape.shape_pt_lon, shape.shape_pt_lat), 4326) ORDER BY shape.shape_pt_sequence)) AS shape_geog,
        st_length(st_makeline(array_agg(st_setsrid(st_makepoint(shape.shape_pt_lon, shape.shape_pt_lat), 4326) ORDER BY shape.shape_pt_sequence))::geography) / 1000 AS shape_length
    FROM septa.bus_shapes AS shape
    GROUP BY shape.shape_id
)

SELECT
    bus.route_short_name,
    bus.trip_headsign,
    geo.shape_geog,
    st_length(geo.shape_geog::geography) AS shape_length
FROM bus_routes AS bus
INNER JOIN bus_geo AS geo ON bus.shape_id = geo.shape_id
GROUP BY bus.route_short_name, bus.trip_headsign, geo.shape_geog, st_length(geo.shape_geog::geography)
ORDER BY st_length(geo.shape_geog::geography) DESC
LIMIT 2
