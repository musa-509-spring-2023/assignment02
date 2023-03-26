 with neighborhoods as (
    select
        mapname as neighborhood,
        geom
    from
        azavea.neighborhoods
), nbhd_data as (
select
	nbhd.neighborhood,
	nbhd.geom,
	sum(case when (bus_stops.wheelchair_boarding = 1) then 1 else 0 end) as some_accessibility,
	sum(case when (bus_stops.wheelchair_boarding = 2) then 1 else 0 end) as no_accessibility,
	sum(case when (bus_stops.wheelchair_boarding = 0) then 1 else 0 end) as unknown_accessibility
from neighborhoods as nbhd, septa.bus_stops as bus_stops
where
	ST_Contains(nbhd.geom::geometry, bus_stops.geom::geometry)
group by
	nbhd.neighborhood,
	nbhd.geom
), final_table as (
select
	neighborhood as neighborhood_name,
	round(cast((some_accessibility::float/(some_accessibility + no_accessibility + unknown_accessibility)) as numeric), 3) as accessibility_metric,
	some_accessibility as num_bus_stops_accessible,
	(no_accessibility + unknown_accessibility) as num_bus_stops_inaccessible
from nbhd_data 
)

select * from final_table order by accessibility_metric desc limit 5;