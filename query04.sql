/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

Your query should run in under two minutes.

HINT: The ST_MakeLine function is useful here. You can see an example of how you could use it at this MobilityData walkthrough on using GTFS data. If you find other good examples, please share them in Slack.

HINT: Use the query planner (EXPLAIN) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds.

HINT: The row_number window function could also be useful here. You can read more about window functions in the PostgreSQL documentation. That documentation page uses the rank function, which is very similar to row_number. For more info about window functions you can check out:

📑 An Easy Guide to Advanced SQL Window Functions in Towards Data Science, by Julia Kho
🎥 SQL Window Functions for Data Scientists (and a follow up with examples) on YouTube, by Emma Ding
Structure:

(
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_geog geography,  -- The shape of the trip
    shape_length double precision  -- Length of the trip in meters
)
*/

--make line geogs from shape lat/lons and sequences
--make sure it has a shape_id
--join shape_id to route_id


-- create geog of bus shapes:
-- INSERT INTO geog
-- SELECT shape_id, ST_MakeLine(array_agg(
--   ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326)::geography ORDER BY shape_pt_sequence))
-- FROM septa.bus_shapes
-- GROUP BY shape_id;

--create spatial index of bus shapes:
-- create index if not exists septa_bus_shapes__geog__idx
-- on septa.bus_shapes using gist
-- (geog);


--EXPLAIN
with trip_lengths as (
    select
        shape_id,
        shape_geom as shape_geog,
        st_length(shape_geom)::DOUBLE PRECISION as line_distance
    from septa.shape_geogs
    group by shape_id, shape_geom
    order by line_distance desc
    limit 2
),

shape_trips_combo as (
    select
        trip_lengths.shape_id,
        trip_lengths.shape_geog,
        trip_lengths.line_distance,
        bus_trips.shape_id,
        bus_trips.route_id,
        bus_trips.trip_headsign
    from trip_lengths
    inner join septa.bus_trips
        on trip_lengths.shape_id = bus_trips.shape_id
    group by trip_lengths.shape_id, trip_lengths.shape_geog, trip_lengths.line_distance, bus_trips.shape_id, bus_trips.route_id, bus_trips.trip_headsign
    order by trip_lengths.line_distance desc
),

routes_combo as (
    select
        shape_trips_combo.shape_geog,
        shape_trips_combo.line_distance,
        shape_trips_combo.route_id,
        shape_trips_combo.trip_headsign,
        bus_routes.route_id,
        bus_routes.route_short_name
    from shape_trips_combo
    inner join septa.bus_routes
        on shape_trips_combo.route_id = bus_routes.route_id
)

select
    route_short_name::TEXT,
    trip_headsign::TEXT,
    shape_geog::GEOGRAPHY,
    line_distance::DOUBLE PRECISION as shape_length
from routes_combo
order by shape_length desc;
