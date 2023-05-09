/*Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. The final result should give the parcel address,
bus stop name, and distance apart in meters. Order by distance (largest on top).*/
WITH nearest_bus_stop AS (
    SELECT
        p.address AS address,
        p.geog,
        s.stop_name,
        ST_Distance(geography(st_setsrid(s.geometry,4326)), geography(p.geog)) AS distance
    FROM
        phl.pwd_parcels as p
    CROSS JOIN LATERAL
        (SELECT geometry, stop_name
        FROM septa.bus_stops 
        ORDER BY
            st_transform(p.geog::geometry,4326) <-> geometry
        LIMIT 1) AS s)

SELECT
    address,
    stop_name,
    distance
FROM nearest_bus_stop
ORDER BY distance DESC