SELECT COUNT(*)
FROM census.blockgroups_2020 AS b
WHERE
    ST_INTERSECTS(ST_GEOMFROMTEXT('POLYGON((-75.18927722389425 39.955400791342757, -75.20170473650431 39.95679597872244, -75.19851818096174 39.94802656127724, -75.19840419155958 39.94804724221181, -75.19069545818966 39.948279029228911, -75.18927722389425 39.955400791342755))', 4326), ST_SETSRID(b.geog, 4326))
