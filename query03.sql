/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. The final result should give the parcel address, 
bus stop name, and distance apart in meters. Order by distance (largest on top).

Your query should run in under two minutes.

Structure:

(
    address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance double precision  -- The distance apart in meters
) */


 --  EXPLAIN
  SELECT 
  p.address::text as address,
  closest_stops.stop_name::text,
  closest_stops.min_distance::DOUBLE PRECISION as distance
  from phl.pwd_parcels as p
  cross join lateral(
    select s.stop_name::text,
    s.geog <-> st_setsrid(p.geog::geography, 4326)::geography as min_distance
    from septa.bus_stops as s
    order by min_distance
    limit 1
  ) closest_stops
  ORDER BY distance desc;

