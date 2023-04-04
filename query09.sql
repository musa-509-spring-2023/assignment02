/*
With a query involving PWD parcels and census block groups,
find the geo_id of the block group that contains Meyerson Hall.
ST_MakePoint() and functions like that are not allowed.
*/


SELECT bg.geo_id
FROM census_block_groups bg, pwd_parcel p
WHERE ST_Contains(bg.geom, ST_Centroid(p.geom))
AND p.address LIKE '%Meyerson Hall%'
