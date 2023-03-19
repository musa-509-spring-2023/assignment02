/*
With a query involving PWD parcels and census block groups, 
find the geo_id of the block group that contains Meyerson Hall. 
ST_MakePoint() and functions like that are not allowed.

Structure (should be a single value):

(
    geo_id text
)
*/

with penn_bgs as (
    select 
pwd_parcels.owner1,
pwd_parcels.address,
pwd_parcels.geog,
blockgroups_2020.geoid as geoid,
blockgroups_2020.geog as bg_geoig
from phl.pwd_parcels
left join census.blockgroups_2020
        on st_within(st_centroid(st_setsrid(pwd_parcels.geog::geometry, 2272)), st_setsrid(blockgroups_2020.geog::geometry, 2272))
--where address = '210 34TH ST'
where pwd_parcels.owner1 LIKE '%UNIV%PENN%' and pwd_parcels.address LIKE '%220%34TH%' -- 210 S 34th isn't available, so 220 S 34th is closest
limit 20)

select
geoid::text as geo_id
from penn_bgs;
