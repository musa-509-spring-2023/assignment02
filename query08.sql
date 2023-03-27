/*
  With a query, find out how many census block groups Penn's main campus fully contains.
  Discuss which dataset you chose for defining Penn's campus.
*/

select count(*) as count_block_groups
from census.blockgroups_2020 as bg
inner join phl.upenn as upenn
    on st_intersects(st_transform(bg.geometry, 4326), upenn.geometry);
