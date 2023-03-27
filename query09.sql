SELECT bg.geoid
FROM census.blockgroups_2020 AS bg
JOIN (
  SELECT *
  FROM phl.pwd_parcels
  WHERE address = '3401-39 WALNUT ST'
) AS pwd
ON ST_Intersects(ST_TRANSFORM(bg.geog::geometry, 4326), ST_TRANSFORM(pwd.geog::geometry,4326))
