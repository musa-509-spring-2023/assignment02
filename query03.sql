SELECT parcels.address, stops.stop_name, stops.distance
FROM phl.pwd_parcels parcels
CROSS JOIN LATERAL (
	SELECT stops.stop_name, stops.geog, stops.geog <-> parcels.geog AS distance
	FROM septa.bus_stops stops
	ORDER BY distance
	LIMIT 1
) stops
ORDER BY distance DESC