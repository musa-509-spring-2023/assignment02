create index parcels_index on phl.pwd_parcels using GiST(geom);


with parcels_stops as (
select
    pwd_parcels.address as parcel_address,
    pwd_parcels.geom as parcel_centroid,
    nearest_bus_stop.stop_name as nearest_stop_name,
	nearest_bus_stop.geom as nearest_stop_point
from phl.pwd_parcels as pwd_parcels
cross join lateral (
    select *
    from septa.bus_stops as bus_stops
    order by pwd_parcels.geom <-> bus_stops.geom
    limit 1
) as nearest_bus_stop
), distances as (	
select
	parcel_address as address,
	nearest_stop_name as stop_name,
	st_distance(parcel_centroid, nearest_stop_point) as distance
from
	parcels_stops
)

select * from distances order by distance desc;