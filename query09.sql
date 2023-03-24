/*
With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.

    **Structure (should be a single value):**
    ```sql
    (
        geo_id text
    )
    ```
*/

WITH 

-- Meyerson Parcels

meyerson AS (
SELECT * FROM phl.pwd_parcels
WHERE address LIKE '%S%' AND address LIKE '%34%'  AND address LIKE '220%'  AND owner1 LIKE '%PENN%'
)


SELECT c.geoid::text AS geo_id
FROM census.blockgroups_2020 AS c
INNER JOIN meyerson AS m
	ON ST_within(ST_TransfoRm(m.geog::geometry, 4236), ST_Transform(c.geog::geometry, 4236))