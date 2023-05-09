-- With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
-- Discussion:
-- I choose azavea.neighborhoods where column "geog" is belong to 'UNIVERSITY_CITY' to define the Penn campus.
SELECT COUNT(a.geog)::integer AS count_block_groups
FROM census.blockgroups_2020 AS a
INNER JOIN (
    SELECT geog
    FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
) AS b
ON ST_WITHIN(ST_TRANSFORM(a.geog::geometry, 4236), ST_TRANSFORM(b.geog::geometry, 4236));
