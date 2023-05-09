/*Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.*/

/*alter table septa.bus_shapes
add column shape_geog geometry(geometry,4326);
update septa.bus_shapes
set shape_geog = st_setsrid(st_makepoint(shape_pt_lat,shape_pt_lon),4326);
*/

with bus_lines as(
select s.shape_id, 
	   st_makeline(shape_geog order by shape_pt_sequence)as shape_geog
	   from septa.bus_shapes as s
	   group by s.shape_id
	   )
	   

select distinct trip_headsign, st_length(st_transform(shape_geog,4326))*100000 as shape_length,route_short_name,shape_geog
from bus_lines
join septa.bus_trips using (shape_id)
join septa.bus_routes using (route_id)
order by shape_length desc
limit 2


