/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

Your query should run in under two minutes.
*/
WITH route_shapes AS (
  SELECT
    shape_id,
    ST_MakeLine(ST_MakePoint(shape_pt_lon, shape_pt_lat) ORDER BY shape_pt_sequence) AS shape_geog
  FROM
    septa.bus_shapes
  GROUP BY
    shape_id
),
trip_shapes AS (
  SELECT
    septa.bus_trips.trip_id,
    shape_geog,
    ST_Length(shape_geog::geography) AS shape_length
  FROM
    route_shapes
    JOIN septa.bus_trips ON septa.bus_trips.shape_id = route_shapes.shape_id
)
SELECT
  septa.bus_routes.route_short_name,
  septa.bus_trips.trip_headsign,
  trip_shapes.shape_geog,
  trip_shapes.shape_length
FROM
  septa.bus_routes
  JOIN septa.bus_trips ON bus_routes.route_id = bus_trips.route_id
  JOIN trip_shapes ON trip_shapes.trip_id = bus_trips.trip_id
WHERE
  bus_routes.route_type::integer = 3  -- Only include bus routes
ORDER BY
  trip_shapes.shape_length DESC
LIMIT 2


