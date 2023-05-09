with school_parcels as (
select
	s.school_name,
	s.parcel_id,
	parcels.geog
from phl.schools as s
inner join phl.pwd_parcels as parcels
on (s.parcel_id =parcels.parcelid)
where s.school_name = 'University of Pennsylvania' and s.building_description like 'SCHOOL %'
), penn_census_blocks as (
select
	sp.geog,
	sp.school_name,
	count(distinct bg.geoid) as bg_count
from school_parcels as sp, census.blockgroups_2020 as bg
where
	ST_Within(ST_Transform(sp.geog::geometry, 4326)::geometry, ST_Transform(bg.geog::geometry, 4326))
group by
	sp.geog,
	sp.school_name
)
select sum(bg_count) as count_block_groups from penn_census_blocks;
