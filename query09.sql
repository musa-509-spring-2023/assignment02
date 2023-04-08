WITH meyerson_parcels AS (
    SELECT *
    FROM phl.pwd_parcels
    WHERE address LIKE '%S%' AND address LIKE '%34%' AND address LIKE '220%' AND owner1 LIKE '%PENN%'
)

SELECT cb.geoid::text AS geo_id
FROM census.blockgroups_2020 AS cb
INNER JOIN meyerson_parcels AS m
           ON ST_INTERSECTS(ST_TRANSFORM(m.geog::geometry, 4236), ST_TRANSFORM(cb.geog::geometry, 4236))
LIMIT 1;
