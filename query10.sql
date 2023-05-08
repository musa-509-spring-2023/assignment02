WITH DESCR AS (
    SELECT
        RS.STOP_NAME,
        CASE
            WHEN COALESCE(COUNT(CI.OGC_FID), 0) < 100 THEN 'This station is SAFE, where there are ' || COALESCE(COUNT(CI.OGC_FID), 0) || ' incidents in 2022 within 3 km'
            WHEN COALESCE(COUNT(CI.OGC_FID), 0) >= 100 AND COALESCE(COUNT(CI.OGC_FID), 0) < 500 THEN 'This station is MODERATELY SAFE, where there are ' || COALESCE(COUNT(CI.OGC_FID), 0) || ' incidents in 2022 within 3 km'
            WHEN COALESCE(COUNT(CI.OGC_FID), 0) >= 500 THEN 'This station is UNSAFE, where there are ' || COALESCE(COUNT(CI.OGC_FID), 0) || ' incidents in 2022 within 3 km'
            ELSE 'Need Info'
        END AS STOP_DESC
    FROM SEPTA.RAIL_STOPS AS RS
    LEFT JOIN PHL.INCIDENTS AS CI
        ON ST_DISTANCESPHERE(ST_MAKEPOINT(RS.STOP_LON::numeric, RS.STOP_LAT::numeric), ST_MAKEPOINT(CI.LNG::numeric, CI.LAT::numeric)) <= 3000
    GROUP BY RS.STOP_NAME
)

SELECT
    RS.STOP_ID::integer,
    RS.STOP_NAME,
    DESCR.STOP_DESC,
    RS.STOP_LON::double precision,
    RS.STOP_LAT::double precision
FROM SEPTA.RAIL_STOPS AS RS
INNER JOIN DESCR
    ON RS.STOP_NAME = DESCR.STOP_NAME
