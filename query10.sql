with census_tracts as (
select
	(bg.statefp || bg.countyfp || bg.tractce) as census_tract,
	ST_Union(bg.geog::geometry) as geom
from
	census.blockgroups_2020 as bg
where
	(bg.statefp || bg.countyfp) = '42101'
group by
	(bg.statefp || bg.countyfp || bg.tractce)
), census_tracts_comm as (
select
	*
from census_tracts as ce
inner join (select comm.geoid, comm.average_label from phl.avg_commute as comm) comm
on (cast(ce.census_tract as numeric) = comm.geoid)
), comm_rail as (
select 
	rail.stop_id,
	rail.stop_name,
	rail.stop_lon,
	rail.stop_lat,
	ce.average_label
from septa.rail_stops as rail, census_tracts_comm as ce
where ST_Within(rail.geom::geometry, ce.geom)
group by rail.stop_id,
	rail.stop_name,
	rail.stop_lon,
	rail.stop_lat,
	ce.average_label
)
select 
	cr.stop_id::integer,
	cr.stop_name,
	('This Census Tract Has ' || cr.average_label || ' Commute Time') as stop_desc,
	cr.stop_lon,
	cr.stop_lat
from comm_rail as cr;