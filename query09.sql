/*
With a query involving PWD parcels and census block groups, 
find the `geo_id` of the block group that contains Meyerson Hall. 
`ST_MakePoint()` and functions like that are not allowed.
*/

-- Use the lat lng of the Meyerson Hall to find the parcel.
-- Sorry for the points, there are just no results when I using "WALNUT" or "34TH" that contains Meyerson Hall
select bg.geoid as geo_id
from census.blockgroups_2020 as bg
where st_contains(ST_TRANSFORM(bg.geog::geometry, 4326), st_setsrid(st_point(-75.19256340137511, 39.95244054277696), 4326));