/*
With a query, find out how many census block groups Penn's main campus fully
contains. Discuss which dataset you chose for defining Penn's campus.
*/


/* The dataset from Open Philly Data is used to define the PEnn's campus.

 */

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
WHERE ST_CONTAINS((SELECT ST_UNION(geometry) FROM census.block_upenn_2020), bg.geometry)
