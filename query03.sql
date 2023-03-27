/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give the
  parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

-- Create spatial indices
CREATE INDEX pwd_parcels_geog_idx ON phl.pwd_parcels USING GIST (geog);
CREATE INDEX bus_stops_geog_idx ON septa.bus_stops USING GIST (geog);

select
    parcels.address,
    stop.stop_name,
    st_distance(parcels.geog, stop.geog) as distance
from phl.pwd_parcels as parcels
cross join lateral (
     select stops.stop_name,
            stops.geog
     from septa.bus_stops as stops
     order by parcels.geog <-> stops.geog
     limit 1
) as stop
order by distance desc;





