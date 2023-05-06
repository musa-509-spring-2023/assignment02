/*With a query, find out how many census block groups Penn's main campus fully contains.
Discuss which dataset you chose for defining Penn's campus.*/
SELECT COUNT(*)
FROM census.blockgroups_2020 AS b
WHERE ST_INTERSECTS(
    ST_GEOMFROMTEXT('POLYGON((-75.201683 39.951117, -75.188747 39.951117, -75.188747 39.956407, -75.201683 39.956407, -75.201683 39.951117))', 4326),
    ST_SETSRID(b.geog::geography, 4326)
);
/*In this query, a polygon is created using the ST_GeomFromText function to define the boundaries of Penn's main campus.
The ST_Intersects function is then used to find the census block group that intersects that polygon.
Finally, the COUNT function is used to calculate the number of census block groups that completely contain that point.*/
