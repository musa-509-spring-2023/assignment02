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
    p.geometry <-> s.geometry
LIMIT
    1;
