/*
 Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
 The final result should give the parcel address, bus stop name, and distance apart in meters. 
 Order by distance (largest on top).
*/

WITH septa_stops AS (
	SELECT
		stops.stop_name,	
		ST_MAKEPOINT(stop_lon, stop_lat)::geography AS geog
	FROM septa.bus_stops AS stops
)

SELECT 
	bus_stops.stop_name,	
	bus_stops.geog
FROM septa_stops AS bus_stops
CROSS JOIN LATERAL (
  SELECT 
		parcels."ADDRESS" AS address,
		bus_stops.stop_name,
		parcels.geometry <-> bus_stops.geog AS distance
  FROM phl.pwd_parcels AS parcels
  ORDER BY distance DESC
	LIMIT 5
) parcels
