SELECT blocks.geoid
FROM phl.pwd_parcels parcels
WHERE parcels.address::text = '3401-39 WALNUT ST'
INNER JOIN (
    SELECT
        blocks.geoid,
        blocks.geog
    FROM census.blockgroups_2020 AS blocks
) blocks ON st_intersects(st_setsrid(blocks.geog::geography, 4326), st_setsrid(parcels.geog::geography, 4326))

