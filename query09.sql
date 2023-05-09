with 

meyerson as (
	select pwd.geom
	from phl.pwd_parcels as pwd
	where pwd.address = '220-30 S 34TH ST'
)

select 
bg.geoid 
from census.blockgroups_2020 as bg
join meyerson on st_intersects(bg.geog::geometry, st_centroid(meyerson.geom))