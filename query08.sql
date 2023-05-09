with

ucity as (
	select 
	nbhd.mapname,
	nbhd.geog
	from azavea.neighborhoods as nbhd
	where nbhd.mapname = 'University City'
)

select count(bg.*) as count_block_groups
from census.blockgroups_2020 as bg
join ucity on st_contains(ucity.geog::geometry, bg.geog::geometry)