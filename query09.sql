/*
  With a query involving PWD parcels and census block groups,
  find the geo_id of the block group that contains Meyerson Hall.
  ST_MakePoint() and functions like that are not allowed.
*/

select geoid as geo_id
from census.blockgroups_2020
where st_contains(geometry, st_setsrid(st_point(-75.19256340137511, 39.95244054277696), 4269));

