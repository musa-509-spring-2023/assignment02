SELECT
  bg.ogc_fid
FROM
  census.blockgroups_2020 bg
JOIN
  (
    SELECT geog
    FROM phl.pwd_parcels
    WHERE address = '210 S 34TH ST'
    LIMIT 1
  ) pwd
ON ST_Intersects(pwd.geog, bg.geog)
LIMIT 1;