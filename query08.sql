/*


With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

Structure (should be a single value):

(
    count_block_groups integer
)

*/

select count(
	distinct c.* )as count_block_groups
from census.blockgroups_2020 as c
inner join (select * from phl.pwd_parcels as p
        where p.owner1 like 'TRS UNIV OF PENN' or p.owner2 like 'TRS UNIV OF PENN' ) a
         on st_intersects(c.geog::geography, a.geog::geography)



