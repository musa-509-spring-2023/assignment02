/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters. 
Order by distance (largest on top).
*/

SELECT
    parcel.address, 
    stop.stop_name,
    ST_DISTANCE(parcel.geog, stop.geog) AS distance
FROM phl.pwd_parcels AS parcel 
CROSS JOIN LATERAL (
    SELECT stop_name, geog 
    FROM septa.bus_stops
    ORDER BY parcel.geog <-> geog -- Use KNN operator to find closest stop
    LIMIT 1
) AS stop
ORDER BY distance DESC;