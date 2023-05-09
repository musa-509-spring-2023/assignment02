select
    pwd.address as parcel_address,
    stops.stop_name,
    st_distance(pwd.geog, stops.geog) as distance  -- noqa: L027
from phl.pwd_parcels as pwd -- noqa: L031
cross join lateral (
        select
            stops.stop_name,
            stops.geog,
            stops.geog <-> pwd.geog as dist -- noqa: PRS
        from septa.bus_stops as stops -- noqa: L031
        order by dist  -- noqa
        limit 1
) stops -- noqa: L011
order by dist desc;

