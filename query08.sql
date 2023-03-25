with -- noqa

penn_collect as (
    select ST_COLLECT(geog::geometry)
    from phl.universities as univ
    where name = 'University of Pennsylvania'
        and st_dwithin('SRID=4326;POINT(-75.1925955 39.9524158)'::geometry,
                univ.geog::geometry, .015))
),

penn_outline as (
    select ST_ENVELOPE(st_collect) as outline
    from penn_collect
)

select COUNT(*)
from census.blockgroups_2020 as bg, penn_outline
where ST_WITHIN(ST_SETSRID(bg.geog::geometry, 4326),
    ST_SETSRID(penn_outline.outline::geometry, 4326))
