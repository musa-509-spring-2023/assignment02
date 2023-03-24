/*Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. The final result should give the parcel address,
 bus stop name, and distance apart in meters. 
Order by distance (largest on top).

Your query should run in under two minutes.

_HINT: This is a nearest neighbor problem.*/
SELECT 
    p.address AS address, 
    b.stop_name AS stop_name, 
    ST_Distance(p.geog, b.geog) AS distance
FROM 
    phl.pwd_parcels AS p 
    CROSS JOIN LATERAL (
        SELECT 
            stop_name, 
            geog 
        FROM 
            septa.bus_stops 
        ORDER BY 
            p.geog <-> geog 
        LIMIT 1
    ) AS b 
ORDER BY 
    distance DESC;
