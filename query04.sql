/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
HINT: The ST_MakeLine function is useful here. You can see an example of how you could use it at this 
      MobilityData walkthrough on using GTFS data. If you find other good examples, please share them in Slack.

HINT: Use the query planner (EXPLAIN) to see if there might be opportunities to speed up your query with indexes.
      For reference, I got this query to run in about 15 seconds.

HINT: The row_number window function could also be useful here. You can read more about window functions in the PostgreSQL documentation.
     That documentation page uses the rank function, which is very similar to row_number.

Structure:

(
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_geog geography,  -- The shape of the trip
    shape_length double precision  -- Length of the trip in meters
)

*/

with shape as (
select shape_id,
		ST_MakeLine(array_agg(ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) order by shape_pt_sequence)) as shape_geog
from septa.bus_shapes
group by shape_id),

trshape as(
select trip.trip_headsign, trip.shape_id, trip.route_id,  ST_Length(shape.shape_geog) as shape_length, shape.shape_geog,
	row_number() over(partition by trip.route_id order by ST_Length(shape.shape_geog) desc)as r
	from septa.bus_trips as trip
	inner join shape on shape.shape_id = trip.shape_id)

select 
	route.route_short_name, trshape.trip_headsign, trshape.shape_geog, trshape.shape_length
	from trshape
	inner join septa.bus_routes as route on route.route_id = trshape.route_id
	where  trshape.r = 1 
	order by trshape.shape_length desc
	limit 2
;


