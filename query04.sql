/*
 Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.
 */

/*
septa.bus_shapes
-- shape_geog
-- shape_id

septa.bus_routes
-- route id

septa.bus_trips
-- trip_headsign
-- shape_id
-- route_id
-- service_id
*/


WITH
-- create bus route geography
bus_shape_geog AS (
    SELECT
        shape_id,
        ST_MakeLine(
            ARRAY_AGG(
                ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326)
                ORDER BY shape_pt_sequence
            )
        )::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

-- calculate route length
bus_shape_geog_length AS (
    SELECT
        *,
        ST_Length(shape_geog) AS shape_length
    FROM bus_shape_geog
),

-- combine with trips
bus_shape_geog_length_trips AS (
    SELECT
        shape.*,
        trips.route_id,
        trips.trip_headsign
    FROM bus_shape_geog_length AS shape
    INNER JOIN septa.bus_trips AS trips USING (shape_id)
),

-- combine with routes to get route name
last_result AS (
    SELECT
        routes.route_short_name,
        trips.trip_headsign,
        trips.shape_length,
        trips.shape_geog
    FROM bus_shape_geog_length_trips AS trips
    INNER JOIN septa.bus_routes AS routes USING (route_id)
    ORDER BY trips.shape_length DESC
)

-- select the two routes with the longest trips
SELECT DISTINCT *
FROM last_result
ORDER BY shape_length DESC
LIMIT 2;
