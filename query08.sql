/*

With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

*/

with upenn_campus as (
    select st_union(geog::geometry) as campus_geom
    from phl.pwd_parcels
    where owner1 like '%UNIV OF PENN%'
        pr owner1 like '%TRUSTEES OF THE UNIVERSIT%'
        or owner1 like '%TRUSTEES OF UNIVERSITY OF PA%'
        or owner1 like '%UNIVERSITY OF PENN%'
        or owner2 like '%UNIVERSITY OF PA%'
        or address like '%3916-22 LOCUST WALK%'
        or owner1 like '%DELTA ALUMNI ASSOC%'
        or owner2 like '%KAPPA SIGMA FRATERNITY%'
        or owner1 like '%PHI PHI CLUB OF ALPHA%'
)

--count the number of block groups that are fully contained in the campus
select count(*) as count_block_groups
from census.blockgroups_2020
where st_contains((select campus_geom from upenn_campus), geog::geometry)
