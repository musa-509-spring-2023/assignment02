/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

Your query should run in under two minutes.
*/

WITH routes_and_trips AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        s.shape_id,
        ST_MakeLine(ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat)::geometry ORDER BY s.shape_pt_sequence) AS shape_geom
    FROM
        bus_routes r
        INNER JOIN bus_trips t ON r.route_id = t.route_id
        INNER JOIN bus_shapes s ON t.shape_id = s.shape_id
),
route_lengths AS (
    SELECT
        route_short_name,
        trip_headsign,
        ST_Length(shape_geom::geography) AS shape_length
    FROM
        routes_and_trips
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geom::geography AS shape_geog,
    shape_length
FROM
    routes_and_trips
    JOIN route_lengths USING (route_short_name, trip_headsign)
WHERE
    shape_length IN (
        SELECT
            DISTINCT shape_length
        FROM
            route_lengths
        ORDER BY
            shape_length DESC
        LIMIT
            2
    )
ORDER BY
    shape_length DESC;



