/*
8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

    **Structure (should be a single value):**
    ```sql
    (
        count_block_groups integer
    )
    ```
    **Discussion:**

*/

WITH univ_boundary AS (
    SELECT * FROM azavea.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
)
SELECT COUNT(a.geog)::integer AS count_block_groups
FROM census.blockgroups_2020 AS a
INNER JOIN univ_boundary AS b
    ON ST_WITHIN(ST_TRANSFORM(a.geog::geometry, 4236),  ST_TRANSFORM(b.geog::geometry, 4236));
