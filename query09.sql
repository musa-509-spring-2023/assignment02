WITH pwd_parcels AS (
    SELECT * FROM phl.pwd_parcels
    WHERE address = '3401-39 WALNUT ST'
)

SELECT bg.geoid FROM census.blockgroups_2020 AS bg
INNER JOIN pwd_parcels AS pwd ON ST_INTERSECTS(ST_TRANSFORM(bg.geog::geometry, 4326), ST_TRANSFORM(pwd.geog::geometry, 4326))
