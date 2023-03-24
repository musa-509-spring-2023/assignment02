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

WITH

univ_boundary AS (
SELECT * FROM azavea.neighborhoods
WHERE name = 'UNIVERSITY_CITY'
)

SELECT COUNT(a.geog)::integer AS count_block_groups
FROM census.blockgroups_2020 as a
INNER JOIN univ_boundary as b
	ON ST_within(ST_Transform(a.geog::geometry, 4236),  ST_Transform(b.geog::geometry, 4236))

