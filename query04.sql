with 
shape as (
	SELECT shape_id, ST_MakeLine(array_agg(
	  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326)ORDER BY shape_pt_sequence))::geography 
	FROM septa.bus_shapes
	GROUP BY shape_id
	),
	
trips as (
	select
		bus_trips.route_id,
		bus_trips.shape_id,
		bus_trips.trip_headsign 
	from septa.bus_trips
	)
	
select 
	routes.route_short_name,
	trips.trip_headsign,
	st_length(shape.st_makeline) as shape_length,
	shape.st_makeline as shape_geog
from shape
left join trips on 
	shape.shape_id = trips.shape_id
left join septa.bus_routes as routes
	on routes.route_id = trips.route_id
group by routes.route_short_name, trips.trip_headsign,shape_length, shape_geog
order by shape_length desc
limit 2


	