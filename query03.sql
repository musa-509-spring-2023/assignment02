/*
3.  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

    _Your query should run in under two minutes._

    >_**HINT**: This is a [nearest neighbor](https://postgis.net/workshops/postgis-intro/knn.html) problem.

    **Structure:**
    ```sql
    (
        address text,  -- The address of the parcel
        stop_name text,  -- The name of the bus stop
        distance double precision  -- The distance apart in meters
    )
    ```
    psql -U postgres -d <hw> -f db_structure.sql
*/
SELECT parcels.address as address,
	   stops.stop_name as stop_name,
       dist as distance
FROM phl.pwd_parcels as parcels
CROSS JOIN LATERAL (
  SELECT parcels.address, stops.stop_name, stops.geog,  parcels.geog<-> stops.geog AS dist
  FROM septa.bus_stops as stops
  ORDER BY dist
  LIMIT 1
) stops;