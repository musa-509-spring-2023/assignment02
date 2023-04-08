
SELECT
    pwd.address AS parcel_address,
    stops.stop_name AS stop_name,
    st_distance(stops.geog,pwd.geog) AS distance
FROM phl.pwd_parcels AS pwd
CROSS JOIN LATERAL (
    SELECT
		stops.geog,
        stops.stop_name,
        stops.geog <-> pwd.geog AS dist
    FROM septa.bus_stops AS stops
    ORDER BY dist
    LIMIT 1
) AS stops
ORDER BY distance DESC

