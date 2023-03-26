WITH penn_parcels AS (
    SELECT
        bg."GEOID" AS geoid,
        penn."OBJECTID" AS penn_parcel
    FROM census.blockgroups_2020 AS bg
    INNER JOIN phl.penn AS penn ON st_intersects(bg.geog, penn.geog)
)

SELECT count(geoid) AS count_block_groups FROM penn_parcels
