select 
	stops.stop_name as stop_name,
    parc.address as parcel_address,
	parc.geog <-> stops.geog as dist
from phl.pwd_parcels as parc
cross join lateral (
	select 
    	stops.stop_name,
    	stops.geog,
		parc.geog <-> stops.geog
    from septa.bus_stops as stops
    limit 1
) as stops
order by dist desc;