SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
WHERE ST_WITHIN(ST_TRANSFORM(bg.geog::geometry, 4326), ST_TRANSFORM((SELECT geog::geometry FROM azavea.neighborhoods WHERE name = 'UNIVERSITY_CITY')::geometry, 4326))
