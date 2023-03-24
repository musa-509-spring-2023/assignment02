/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

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
*/

SELECT septa.bus_stops.geog <-> ST_Transform(phl.pwd_parcels.geog::geometry, 4326) AS dist
FROM septa.bus_stops, phl.pwd_parcels


SELECT parcel.address, bus.stop_name, bus.dist AS distance
FROM  phl.pwd_parcels AS parcel
CROSS JOIN LATERAL (
  SELECT  bus.stop_name, bus.geog <-> parcel.geog AS dist
  FROM septa.bus_stops AS bus
  ORDER BY dist
  LIMIT 1
) bus;


SELECT subways.gid AS subway_gid,
       subways.name AS subway,
       streets.name AS street,
       streets.gid AS street_gid,
       streets.geom::geometry(MultiLinestring, 26918) AS street_geom,
       streets.dist
FROM nyc_subway_stations subways
CROSS JOIN LATERAL (
  SELECT streets.name, streets.geom, streets.gid, streets.geom <-> subways.geom AS dist
  FROM nyc_streets AS streets
  ORDER BY dist
  LIMIT 1
) streets;