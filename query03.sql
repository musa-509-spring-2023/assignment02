/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. The final result should give the
parcel address, bus stop name, and distance apart in meters. Order by distance
(largest on top).

Your query should run in under two minutes.
*/





SELECT
    p."ADDRESS",
    s.stop_name,
    ST_Distance(p.geometry::geography, s.geometry::geography) AS distance
FROM
    phl.pwd_parcels p
CROSS JOIN
    septa.bus_stops s
ORDER BY
    p.geometry <-> s.geography
LIMIT
    1

WITH closest_stops AS (
    SELECT
        p."PARCELID",
        s.stop_id,
        s.stop_name AS stop_name,
        ST_Distance(p.geometry, s.geography) AS distance,
        ROW_NUMBER() OVER (PARTITION BY p."PARCELID" ORDER BY ST_Distance(p.geometry, s.geography)) AS rn
    FROM phl.pwd_parcels p
    CROSS JOIN LATERAL (
        SELECT stop_id, stop_name, geography
        FROM septa.bus_stops
        ORDER BY p.geometry <-> geography
        LIMIT 1
    ) s
)
SELECT
    p."ADDRESS" AS parcel_address,
    cs.stop_name,
    cs.distance
FROM phl.pwd_parcels p
JOIN closest_stops cs ON p."PARCELID" = cs."PARCELID" AND cs.rn = 1
ORDER BY cs.distance DESC