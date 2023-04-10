/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

SELECT 
	bus.stop_name,
	parcel.address AS parcel_address,
	parcel.dist AS distance,
	bus.geom
FROM septa.bus_stops AS bus
CROSS JOIN LATERAL(
	SELECT 
		parcel.address,
		parcel.geom,
		parcel.geom <-> bus.geom AS dist
	FROM phl.pwd_parcels AS parcel
	ORDER BY dist
	LIMIT 1			
)

//https://postgis.net/workshops/postgis-intro/knn.html
