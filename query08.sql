SELECT COUNT(*) AS num_blockgroups
FROM census.blockgroups_2020 AS bg
INNER JOIN (
    SELECT
        boundary.geog,
        boundary.name
    FROM penn.boundary AS boundary_a
    WHERE boundary_a.name = 'University of Pennsylvania'
) boundary_a ON ST_INTERSECTS(ST_SETSRID(bg.geog::geography, 4326), ST_SETSRID(boundary.geog::geography, 4326))
/*for penn campus boundary, i chose the philadlephia universities and colleges data set
by the city of philadlephia, which defined penn campus as well as other univeristies in the city.*/
