with meyerson as (
select
	parcels.parcelid,
	parcels.geog
from phl.pwd_parcels as parcels
where address = '220-30 S 34TH ST'
)
select cast(bg.geoid as text) as geoid 
from census.blockgroups_2020 as bg, meyerson as m
where ST_Within(ST_Transform(m.geog::geometry, 4326), ST_Transform(bg.geog::geometry, 4326));