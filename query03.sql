/*

Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. The final result should give the parcel address, 
bus stop name, and distance apart in meters. Order by distance (largest on top).

Your query should run in under two minutes.

_HINT: This is a nearest neighbor problem.

*/

select
    parcels.address as parcel_address,
    parcels.geog as parcel_geog,
    stops.stop_name as stop_name,
    stops.geog as stop_geog,
    stops.dist as distance
from phl.pwd_parcels as parcels
cross join lateral (
    select stops.stop_name, stops.geog, stops.geog <-> parcels.geog as dist
    from septa.bus_stops as stops
    order by dist
    limit 1
) stops
order by distance desc
limit 5;