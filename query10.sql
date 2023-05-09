/*You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
and PostgreSQL string functions, build a description (alias as stop_desc) for each stop.
Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.*/

/*description: calculate the rail stops' distance to its nearest bus stop*/
with nearest_bus_stops as(
	select r.stop_id, r.stop_name, r.stop_lon, r.stop_lat,bus_stop_name,
	st_distance(geography(st_setsrid(st_makepoint(stop_lon,stop_lat),4326)),st_setsrid(b.geog,4326)) as distance
	from septa.rail_stops as r
	cross join lateral(
	select geog, stop_name as bus_stop_name
	from septa.bus_stops 
	order by st_setsrid(st_makepoint(stop_lon,stop_lat),4326)<-> st_setsrid(geometry,4326)
	limit 1
	)as b )

select stop_id, stop_name, stop_lon, stop_lat, distance ||' meters to its nearest bus stop '|| bus_stop_name  as stop_desc
from nearest_bus_stops
order by distance desc

