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
    ST_Distance(p.geometry, s.geography) AS distance
FROM
    phl.pwd_parcels AS p
    CROSS JOIN LATERAL (
        SELECT
            stop_name,
            geometry
        FROM
            septa.bus_stops
        ORDER BY
            p.geometry <-> geography
        LIMIT 1
    ) AS s
ORDER BY
    distance DESC

