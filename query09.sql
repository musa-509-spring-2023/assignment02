/*
With a query involving PWD parcels and census block groups,
find the geo_id of the block group that contains Meyerson Hall.
ST_MakePoint() and functions like that are not allowed.
*/


SELECT bg.geoid as geo_id
FROM census.population_2020 as bg
WHERE ST_CONTAINS(bg.geometry, ST_SETSRID(ST_POINT(-75.19256340137511, 39.95244054277696), 4269));