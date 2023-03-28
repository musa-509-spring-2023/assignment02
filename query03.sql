SELECT
    pwd.address AS address,
    stops.stop_name AS stop_name,
    ST_DISTANCE(pwd.geog, stops.geog) AS distance
FROM phl.pwd_parcels AS pwd
CROSS JOIN LATERAL (
    SELECT
        stops.stop_name,
        stops.geog
    FROM septa.bus_stops AS stops
    ORDER BY stops.geog < - > pwd.geog
    LIMIT 1
) AS stops
ORDER BY distance DESC
