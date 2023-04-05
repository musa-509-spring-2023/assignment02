SELECT blocks.geoid
    FROM phl.pwd_parcels parcels
    INNER JOIN 
        (
        SELECT blocks.geoid, blocks.geog
        FROM census.blockgroups_2020 blocks
        ) blocks on st_intersects(st_setsrid(blocks.geog :: geography, 4326), st_setsrid(parcels.geog :: geography, 4326))
WHERE parcels.address :: text = '3401-39 WALNUT ST'

