/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

SELECT 
    parcels.address AS parcel_address,
    parcels.geog AS parcel_geog,
    join_table.stop_name,
    join_table.geog AS stop_geog,
    join_table.dist AS distance
FROM phl.pwd_parcels AS parcels
CROSS JOIN LATERAL(
SELECT 
    bus.stop_name,
    bus.geog,
    parcels.geog <-> bus.geog AS dist
    FROM septa.bus_stops AS bus
    ORDER BY dist
    LIMIT 1			
) AS join_table
ORDER BY dist DESC
LIMIT 5
