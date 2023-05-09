/*


With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

Structure (should be a single value):

(
    geo_id text
)

*/

select count(*)as geo_id
from census.blockgroups_2020 as c
inner join(
    select * from phl.pwd_parcels as p
    where p.address::text like '221 S 34TH ST') as a
where st_contains(ST_SetSRID(c.geog, 4326),ST_SetSRID(a.geog, 4326))
