/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

SELECT septa.bus_stops.geog <-> ST_Transform(phl.pwd_parcels.geog::geometry, 4326) AS dist
FROM septa.bus_stops, phl.pwd_parcels


