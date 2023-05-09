with stops_blocks as (
select
	stops.stop_id,
	stops.stop_name,
	stops.geom,
	blockgroups.geoid
from septa.bus_stops as stops
inner join (
	select bg.geoid, bg.geog from census.blockgroups_2020 as bg
) blockgroups
on st_dwithin(stops.geom, blockgroups.geog, 800)
), stops_blocks_pop as ( 
select 
	stops_blocks.stop_name,
	stops_blocks.geom,
	pop.total
from stops_blocks 
inner join census.population_2020 as pop
on (('1500000US' || stops_blocks.geoid) = pop.geoid)
), final_table as (
select
	stop_name,
	geom,
	sum(total) as estimated_pop_800m
from 
	stops_blocks_pop
group by 
	stop_name,
	geom
order by
	estimated_pop_800m asc
)

select * from final_table where estimated_pop_800m >= 500 limit 8;