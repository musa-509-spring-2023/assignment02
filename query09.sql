select bg.geoid as geo_id
from census.blockgroups_2020 as bg
where st_contains(bg.geometry, st_setsrid(st_point(-75.19256340137511, 39.95244054277696), 4269));