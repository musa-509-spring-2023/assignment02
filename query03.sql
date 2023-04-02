SELECT
    pwd.address AS parcel_address,
    stops.stop_name AS stop_name,
    stops.dist AS distance
FROM phl.pwd_parcels AS pwd
CROSS JOIN LATERAL (
    SELECT
        stops.stop_name,
        stops.geog <-> st_setsrid(pwd.geog, 4326) AS dist
    FROM septa.bus_stops AS stops
    ORDER BY dist
    LIMIT 1
) AS stops
ORDER BY distance DESC
