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

meyerson_near as (
    select
        address,
        geog
    from penn_own
    where
        address like '%34%'
        and address like '%WALNUT%'
),

philly_block as (
    select
        geoid,
        geog
    from census.blockgroups_2020
    where geoid like '42101%'
)

select philly_block.geoid as geo_id
from philly_block
inner join meyerson_near
    on
        st_intersects(
            st_setsrid(philly_block.geog::geography, 4326), meyerson_near.geog
        )
