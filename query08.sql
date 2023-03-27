with -- noqa

penn_collect as (
    select ST_CONCAVEHULL(ST_COLLECT(univ.geog::geometry), .08) as outline
    from phl.universities as univ
    where univ.name = 'University of Pennsylvania'
        and ST_DWITHIN('SRID=4326;POINT(-75.1925955 39.9524158)'::geometry,
            univ.geog::geometry, .012)
)

select COUNT(*)
from census.blockgroups_2020 as bg, penn_collect
where ST_WITHIN(ST_SETSRID(bg.geog::geometry, 4326),
    ST_SETSRID(penn_collect.outline::geometry, 4326))
