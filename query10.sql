WITH Meyerson AS (SELECT *
    FROM Phl.Campus_Buildings
    WHERE Address = '220-30 S 34TH ST'
),

T1 AS (SELECT
    Stop_Id,
    Stop_Name,
    Stop_Lon,
    Stop_Lat,
    ROUND(ST_DISTANCE(Meyerson.Geog, Stops.Geog)),
    CASE
        WHEN ST_AZIMUTH(ST_CENTROID(Meyerson.Geog), Stops.Geog) < 90 THEN 'NE'
        WHEN ST_AZIMUTH(ST_CENTROID(Meyerson.Geog), Stops.Geog) BETWEEN 90 AND 180 THEN 'SE'
        WHEN ST_AZIMUTH(ST_CENTROID(Meyerson.Geog), Stops.Geog) BETWEEN 180 AND 270 THEN 'SW'
        ELSE 'NW'
    END AS Direction
    FROM Septa.Rail_Stops AS Stops, Meyerson
)

SELECT
    Stop_Id,
    Stop_Name,
    Stop_Lon,
    Stop_Lat,
    CONCAT(Round, ' meters ', Direction, ' of Meyerson Hall') AS Stop_Desc
FROM T1
