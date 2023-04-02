/*

    Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

    Your query should run in under two minutes.

(
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_geog geography,  -- The shape of the trip
    shape_length double precision  -- Length of the trip in meters
)

*/

-- get their distances (perhaps as the window function?), sort by distance
--- bus_routes has route_id and route_short_name
--- bus_trips has route_id, trip_headsign, shape_id
--- bus_shapes has shape_id, lat, lon (SKIP)
--- shape_geoms has shape_id and shape_geom

WITH shape_geogs AS (
    SELECT
        shape_id AS shape_id,
        st_transform(shape_geom, 4326)::geography AS shape_geog,
        st_length(st_transform(shape_geom, 4326)::geography) AS length
    FROM septa.shape_geoms
)

SELECT
    routes.route_short_name,
    trips.trip_headsign AS headsign,
    shape_geogs.shape_geog,
    shape_geogs.length AS shape_length
FROM septa.bus_trips AS trips
INNER JOIN septa.bus_routes AS routes
    ON trips.route_id = routes.route_id
INNER JOIN shape_geogs
    ON trips.shape_id = shape_geogs.shape_id
GROUP BY headsign, routes.route_short_name, shape_length, shape_geogs.shape_geog
ORDER BY shape_length DESC
LIMIT 2
