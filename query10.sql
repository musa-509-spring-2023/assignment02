with

all_data as (
    select
        stops.stop_name as stop_name,
        stops.stop_id as stop_id,
        stops.stop_lon as stop_lon,
        stops.stop_lat as stop_lat,
        parcels.owner1 as parcel_ownername,
        parcels.address as address,
        parcels.dist as distance,
        parcels.geog as parcel_geog,
        stops.geog as stop_geog
    from septa.bus_stops as stops
    cross join lateral (
        select
            parcels.owner1,
            parcels.geog,
            parcels.address,
            parcels.geog <-> stops.geog as dist -- noqa: PRS
        from phl.pwd_parcels as parcels
        order by dist -- noqa: L028
        limit 3
    ) as parcels
    order by distance desc
)

select -- noqa: L034
    stop_id,
    stop_name,
    'The PWD parcel nearest to this stop is owned by '
    || parcel_ownername as stop_desc,
    stop_lon,
    stop_lat
from all_data;
