/*
With a query involving PWD parcels and census
block groups, find the geo_id of the block group
that contains Meyerson Hall.  ST_MakePoint() and
functions like that are not allowed.
*/

select bg.geoid as geo_id
from census.blockgroups_2020 as bg
left join phl.pwd_parcels as parcel
    on st_intersects(bg.geog, parcel.geog)
where parcel.address = '220-30 S 34TH ST'



/*
ANSWER: "421010369022"
210 S 34th Street is not an available address,
so 220-30 S 34th is used as a proxy location.
*/
