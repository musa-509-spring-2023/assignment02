with

penn_own as (
    select
        address,
        geog
    from phl.pwd_parcels
    where
        owner1 like '%UNIV OF PENN%'
        or owner2 like '%UNIV OF PENN%'
),

main as (
    select st_convexhull(
            st_collect(st_setsrid(geog::geometry, 4326))
        )::geography as geog
    from penn_own
    where not address = '4625 SPRUCE ST'
        and not address = '212 S 42ND ST'
        and not address = '427 S 45TH ST'
)

select count(*) as count_block_groups
from census.blockgroups_2020
inner join main
    on st_intersects(st_setsrid(census.blockgroups_2020.geog::geography, 4326),
        main.geog)
