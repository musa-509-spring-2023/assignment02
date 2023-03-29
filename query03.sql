select
    pwd.address as parcel_address,
    stops.stop_name,
    dist as distance 
from septa.bus_stops as stops 
cross join lateral (
        select
            pwd.address,
            pwd.geog,
            pwd.geog <-> stops.geog as dist 
        from phl.pwd_parcels as pwd 
        order by dist 
        limit 1
) pwd 
order by dist desc; 
