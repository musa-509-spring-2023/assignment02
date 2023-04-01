SELECT COUNT(*) AS count_block_groups
FROM phl.university AS u
LEFT JOIN census.blockgroups_2020 AS b
    ON ST_COVERS(u.geog, ST_SETSRID(b.geog, 4326))
