select count(*) as count_block_groups
from census.blockgroups_2020 as bg
inner join phl.upenn as upenn
    on st_intersects(st_transform(bg.geometry, 4326), upenn.geometry);
