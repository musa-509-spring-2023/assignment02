WITH uni AS (
    SELECT *
    FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
)

SELECT COUNT(cb.geog)::integer AS count_block_groups
FROM census.blockgroups_2020 AS cb
INNER JOIN uni
           ON ST_WITHIN(ST_TRANSFORM(cb.geog::geometry, 4236), ST_TRANSFORM(uni.geog::geometry, 4236));
