with

meyerson as (
    select *
    from phl.pwd_parcels
    where address like '3401-99%'
)

select bg.geoid as geoid
from census.blockgroups_2020 as bg, meyerson
where ST_WITHIN(meyerson.geog::geometry,
    ST_SETSRID(bg.geog::geometry, 4326))
