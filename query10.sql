WITH rail AS (
    SELECT
        *,
        ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326) AS geog
    FROM septa.rail_stops
),

shapes AS (
    SELECT
        *,
        ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) AS geog
    FROM septa.bus_shapes
)

SELECT DISTINCT
    s.stop_id,
    s.stop_name,
    s.stop_lon,
    s.stop_lat,
    ST_AZIMUTH(s.geog, rs.geog) AS bearing,
    CONCAT(
        'This stop is located ',
        ROUND(ST_DISTANCE(s.geog, rs.geog)), ' meters ',
        CASE
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN 0 AND 45 THEN 'NE'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN 45 AND 90 THEN 'E'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN 90 AND 135 THEN 'SE'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN 135 AND 180 THEN 'S'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN -180 AND -135 THEN 'S'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN -135 AND -90 THEN 'SW'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN -90 AND -45 THEN 'W'
            WHEN ST_AZIMUTH(s.geog, rs.geog) BETWEEN -45 AND 0 THEN 'NW'
            ELSE ''
        END, ' of ', rs.shape_id,
        CASE
            -- Check if the stop is near a parcel
            WHEN ST_DISTANCE(s.geog, b.geog) < 50
                THEN CONCAT('near parcel ', p.parcelid)
            -- Check if the stop is in a block group
            WHEN ST_DWITHIN(ST_SETSRID(s.geog::geography, 4326), ST_SETSRID(bg.geog::geography, 4326), 300)
                THEN CONCAT('in block group', bg.namelsad)
            -- Check if the stop is in a neighborhood
            WHEN ST_DWITHIN(ST_SETSRID(s.geog::geography, 4326), ST_SETSRID(n.geog::geography, 4326), 300)
                THEN CONCAT('in neighborhood ', n.name)
            ELSE ''
        END
    ) AS stop_desc
FROM
    rail AS s
LEFT JOIN septa.bus_stops AS b ON ST_DISTANCE(s.geog, b.geog) < 300
LEFT JOIN phl.pwd_parcels AS p ON ST_DISTANCE(s.geog, p.geog) < 300
LEFT JOIN census.blockgroups_2020 AS bg ON ST_DWITHIN(ST_SETSRID(bg.geog::geography, 4326), ST_SETSRID(s.geog::geography, 4326), 300)
LEFT JOIN
    azavea.neighborhoods AS n ON ST_DWITHIN(ST_SETSRID(n.geog::geography, 4326), ST_SETSRID(s.geog::geography, 4326), 300)
LEFT JOIN
    shapes AS rs ON ST_DISTANCE(s.geog, rs.geog) < 300
WHERE
    s.stop_desc IS NOT NULL
LIMIT 5;
