with 

parcels as (
    select 
        parc.parcelid,
        parc.address,
        ST_Transform(parc.geog::geometry, 4326)::geography as geog
    from phl.pwd_parcels as parc
)

select 
    stops.stop_id as stop,
    stops.stop_name as name,
    stops.geog,
    parc.address
from septa.bus_stops as stops
cross join lateral (
    select
        *,
        stops.geog <-> parcels.geog as dist
    from parcels
    order by dist
    limit 1
) parc;