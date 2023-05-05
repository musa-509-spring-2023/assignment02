WITH myplace AS (
    SELECT *
    FROM phl.pwd_parcels
    WHERE address = '3201 RACE ST'
),

lastt AS (
    SELECT
        stops.stop_id,
        stops.stop_name,
        stops.stop_lon,
        stops.stop_lat,
        stops.geog,
        myplace.geog,
        ST_DISTANCE(ST_SETSRID(ST_CENTROID(myplace.geog), 4326), ST_SETSRID(stops.geog, 4326)) AS dist,
        CASE 
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 22.5 AND 67.5 THEN 'NE'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 67.5 AND 112.5 THEN 'E'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 112.5 AND 157.5 THEN 'SE'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 157.5 AND 202.5 THEN 'S'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 202.5 AND 247.5 THEN 'SW'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 247.5 AND 292.5 THEN 'W'
          WHEN ST_AZIMUTH(ST_CENTROID(myplace.geog), stops.geog) BETWEEN 292.5 AND 337.5 THEN 'NW'
          ELSE 'N'
        END AS direction
    FROM septa.bus_stops AS stops, myplace
)

SELECT
    stop_id,
    stop_name,
    CONCAT(dist, ' meters ', direction, ' of My Apartment') AS stop_desc,
    stop_lon,
    stop_lat
FROM lastt
