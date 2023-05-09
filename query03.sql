/*
Using the Philadelphia Water Department Stormwater Billing 
Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop 
name, and distance apart in meters. Order by distance 
(largest on top).
*/

select 
	parcel.address as parcel_address,
	join_data.stop_name as stop_name,
	join_data.distance
	from phl.pwd_parcels as parcel
	CROSS JOIN LATERAL (
  		SELECT 
		bus.stop_name,
  		parcel.geog <-> bus.geog AS distance
  		FROM septa.bus_stops AS bus
		ORDER BY distance
  LIMIT 1
) as join_data
ORDER BY distance DESC
	limit 5;