/*
for penn campus boundary, i chose the philadlephia universities and colleges data set 
by the city of philadlephia, which defined penn campus as well as other univeristies in the city.
*/
SELECT COUNT(*) as num_blockgroups
FROM census.blockgroups_2020 as bg
INNER JOIN (
    SELECT boundary.geog, boundary.name
    FROM penn.boundary AS boundary
    WHERE boundary.name = 'University of Pennsylvania'
)boundary on st_intersects(st_setsrid(bg.geog :: geography, 4326), st_setsrid(boundary.geog :: geography, 4326))