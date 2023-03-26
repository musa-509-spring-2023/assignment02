WITH meyerson AS (
    SELECT
        bg."GEOID" AS geoid,
        parcel."ADDRESS",
        parcel.geometry
    FROM census.blockgroups_2020 AS bg
    INNER JOIN phl.pwd_parcels AS parcel ON st_intersects(parcel.geometry, bg.geog)
    WHERE parcel."ADDRESS" = '220-30 S 34TH ST'
)

SELECT geoid AS geo_id
FROM meyerson
