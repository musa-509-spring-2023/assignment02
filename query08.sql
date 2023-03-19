/*
With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

Structure (should be a single value):

(
    count_block_groups integer
)
Discussion:
I used the "University City" neighborhood from the Azavea neighborhoods table as my proxy for Penn's main campus.
I chose to use UCity as it is generally considered to be mostly Penn's campus.
*/

with uc_bgs as (
    SELECT
    neighborhoods.mapname as neighborhood_name,
    neighborhoods.geog as n_geog,
    blockgroups_2020.geoid as geoid,
    blockgroups_2020.geog as bg_geoig
    from azavea.neighborhoods
    full join census.blockgroups_2020
        on st_within((st_setsrid(blockgroups_2020.geog::geometry, 2272)), st_setsrid(neighborhoods.geog::geometry, 2272))
    where neighborhoods.mapname = 'University City'
)

SELECT
count(geoid)::INTEGER as count_block_groups
from uc_bgs
group by neighborhood_name;