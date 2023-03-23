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
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))::geography AS shape_geog
FROM septa.bus_shapes
GROUP BY shape_id
),

-- calculate route length

bus_shape_geog_length AS (
SELECT *, ST_Length(bus_shape_geog.shape_geog) AS shape_length
FROM bus_shape_geog
),

-- combine with trips

bus_shape_geog_length_trips AS (
SELECT * 
FROM bus_shape_geog_length as shape
INNER JOIN septa.bus_trips as trips using (shape_id)
),

-- combine with routes to get route name

last_result AS (
	
SELECT b.route_short_name, a.trip_headsign, a.shape_length, a.shape_geog
FROM bus_shape_geog_length_trips AS a
INNER JOIN septa.bus_routes AS b using (route_id)
ORDER BY a.shape_length DESC

) 

-- combine with routes to get route name

SELECT DISTINCT *
FROM last_result
ORDER BY shape_length DESC
LIMIT 2