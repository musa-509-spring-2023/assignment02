/*

    With a query involving PWD parcels and census block groups, find the geoid of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

*/

with meyerson_parcel as (
    select geog::geometry
    from phl.pwd_parcels
    where address like '%S 34TH ST%'
        and bldg_desc like '%SCHOOL%'
    order by shape__are asc
    limit 1
)

select geoid
from census.blockgroups_2020
where st_contains(geog::geometry, (select st_centroid(geog::geometry) from meyerson_parcel))
