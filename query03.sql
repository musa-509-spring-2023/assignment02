select
    pwd.address as parcel_address,
    stops.stop_name,
    dist as distance  -- noqa: L027
from septa.bus_stops as stops -- noqa: L031
cross join lateral (
        select
            pwd.address,
            pwd.geog,
            pwd.geog <-> stops.geog as dist -- noqa: PRS
        from phl.pwd_parcels as pwd -- noqa: L031
        order by dist  -- noqa
        limit 1
) pwd  -- noqa: L011
order by dist desc  -- noqa: L027
