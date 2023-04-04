/*
With a query, find out how many census block groups Penn's main campus fully
contains. Discuss which dataset you chose for defining Penn's campus.
*/


/* The dataset from Open Philly Data is used to define the PEnn's campus.

 */

SELECT COUNT(*) AS num_block_groups
FROM census_block_groups
WHERE ST_Contains(
    (SELECT campus_boundary_geom FROM penn_campus_boundary),
    census_block_groups.geom
);
