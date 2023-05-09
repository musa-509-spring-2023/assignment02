/*With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.*/

select count(*) as count_census_blockgroups
from phl.pwd_parcels as p
join census.blockgroups_2020 as c
on st_contains(st_transform(c.geog::geometry,4326),st_transform(p.geog::geometry,4326))
where p.owner1 = 'TRUSTEES OF THE UNIVERSIT'