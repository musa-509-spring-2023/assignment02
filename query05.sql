select
	nbhd.mapname as neighborhood_name,
	count(stops.*) filter (where wheelchair_boarding = 1)/
	count(stops.*)/st_area(nbhd.geog) as accessibility_metric,
	count(stops.*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
	count(stops.*) filter (where wheelchair_boarding = 2) as num_bus_stops_inaccessible

	
from azavea.neighborhoods as nbhd
inner join septa.bus_stops as stops on
	st_contains(nbhd.geog::geometry, stops.geog::geometry)
group by nbhd.mapname, nbhd.geog
order by  accessibility_metric desc
