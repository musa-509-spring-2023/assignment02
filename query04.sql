-- Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

-- Your query should run in under two minutes.

-- HINT: The ST_MakeLine function is useful here. You can see an example of how you could use it at this MobilityData walkthrough on using GTFS data. If you find other good examples, please share them in Slack.

-- HINT: Use the query planner (EXPLAIN) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds.

-- HINT: The row_number window function could also be useful here. You can read more about window functions in the PostgreSQL documentation. That documentation page uses the rank function, which is very similar to row_number. For more info about window functions you can check out:

-- 📑 An Easy Guide to Advanced SQL Window Functions in Towards Data Science, by Julia Kho
-- 🎥 SQL Window Functions for Data Scientists (and a follow up with examples) on YouTube, by Emma Ding
-- Structure:

-- (
--     route_short_name text,  -- The short name of the route
--     trip_headsign text,  -- Headsign of the trip
--     shape_geog geography,  -- The shape of the trip
--     shape_length double precision  -- Length of the trip in meters
-- )

SELECT DISTINCT ON (bus_routes.route_short_name) 
    bus_routes.route_short_name, 
    septa.bus_trips.trip_headsign, 
    ST_MAKELINE(
        ARRAY_AGG(
            ST_SetSRID(
                ST_MAKEPOINT(septa.bus_shapes.shape_pt_lon, septa.bus_shapes.shape_pt_lat), 
                4326
            )
            ORDER BY septa.bus_shapes.shape_pt_sequence
        )
    ) AS shape_geog,
    ST_LENGTH(
        ST_MAKELINE(
            ARRAY_AGG(
                ST_SetSRID(
                    ST_MAKEPOINT(septa.bus_shapes.shape_pt_lon, septa.bus_shapes.shape_pt_lat), 
                    4326
                )
                ORDER BY septa.bus_shapes.shape_pt_sequence
            )
        )::geography
    ) AS shape_length
FROM septa.bus_trips
JOIN septa.bus_routes ON septa.bus_trips.route_id = septa.bus_routes.route_id
JOIN septa.bus_shapes ON septa.bus_trips.shape_id = septa.bus_shapes.shape_id
GROUP BY bus_routes.route_short_name, septa.bus_trips.trip_headsign
ORDER BY bus_routes.route_short_name, shape_length DESC
LIMIT 2;
