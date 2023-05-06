/*Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. The final result should give the parcel address,
 bus stop name, and distance apart in meters.
Order by distance (largest on top).

Your query should run in under two minutes.

_HINT: This is a nearest neighbor problem.*/
SELECT
    p.address AS address,
    b.stop_name AS stop_name,
    ST_DISTANCE(p.geog, b.geog) AS distance
FROM
    phl.pwd_parcels AS p
CROSS JOIN LATERAL (
        SELECT
            s.stop_name AS stop_name,
            s.geog AS geog
        FROM
            septa.bus_stops AS s
        ORDER BY
            ST_DISTANCE_SPHERE(p.geog, s.geog)
        LIMIT 1
    ) AS b
ORDER BY
    distance DESC;
