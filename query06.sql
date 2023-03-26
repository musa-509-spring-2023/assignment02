/*Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. 
Use the GTFS documentation for help. 
Use some creativity in the metric you devise in rating neighborhoods.
What are the top five neighborhoods according to your accessibility metric?*/
with join_stops_neighborhood as (
	select stop_id, stop_name, geometry, wheelchair_boarding,name as neighborhood_name
	from septa.bus_stops as bs
	join azavea.neighborhoods as an
	on st_contains(st_transform(an.geog::geometry,4326),bs.geometry)
	)

select neighborhood_name,
	   round(count(case when wheelchair_boarding=1 then 1 end)::numeric/count(*),2) as accessibility_metric,
	   count(case when wheelchair_boarding=1 then 1 end)::numeric as num_bus_stops_accessible,
	   count(case when wheelchair_boarding=0 then 0 end)::numeric as num_bus_stops_inaccessible
from join_stops_neighborhood
group by neighborhood_name
order by accessibility_metric desc,num_bus_stops_accessible desc
limit 5
