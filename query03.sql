-- Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

-- Your query should run in under two minutes.

-- _HINT: This is a nearest neighbor problem.

-- Structure:

-- (
--     parcel_address text,  -- The address of the parcel
--     stop_name text,  -- The name of the bus stop
--     distance double precision  -- The distance apart in meters
-- )



SELECT 
    p.address AS address,
    p.geog::geometry(MultiLinestring, 26918) AS parcel_goem,
    s.stop_name AS stop_name,
    s.geog::geometry(MultiLinestring, 26918) AS stop_goem
FROM 
    phl.pwd_parcels p
CROSS JOIN LATERAL 
    (SELECT p.address, s.stop_name, p.geog <-> s.geog AS distance
     FROM septa.bus_stops AS s
     ORDER BY distance
     LIMIT 1) 
    AS s
ORDER BY 
    distance DESC;
