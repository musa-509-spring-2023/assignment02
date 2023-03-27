/*

Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
find the two routes with the longest trips.

Your query should run in under two minutes.

"route_short_name","trip_headsign","shape_geog","shape_length"

*/

WITH

shapes AS (
    SELECT
        shape_id,
        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(
            ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326
            )
            ORDER BY shape_pt_sequence)) AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

tripstab AS (
    SELECT DISTINCT
        trips.trip_headsign,
        trips.shape_id,
        trips.route_id
    FROM septa.bus_trips AS trips
),

tripshape AS (
    SELECT * FROM shapes -- noqa: L027
    LEFT JOIN tripstab
        ON shapes.shape_id = tripstab.shape_id
),

alldata AS (
    SELECT * FROM tripshape -- noqa: L027
    LEFT JOIN septa.bus_routes AS routes
        ON tripshape.route_id = routes.route_id
)

SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    ST_LENGTH(shape_geog::geography) AS shape_length
FROM alldata
ORDER BY shape_length DESC
LIMIT 2;
