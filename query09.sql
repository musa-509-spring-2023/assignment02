/*With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. 
ST_MakePoint() and functions like that are not allowed.*/

with meyerson as (
	select address,owner1,geog
	from phl.pwd_parcels
	where address = '220-30 S 34TH ST'
)

select  b.geoid
from census.blockgroups_2020 as b
join meyerson on st_contains(st_transform(b.geog::geometry,4326),st_transform(meyerson.geog::geometry,4326))