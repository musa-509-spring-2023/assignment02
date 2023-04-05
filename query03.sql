SELECT near.address AS address,
bus_stops.stop_name AS stop_name,
near.dist AS dist,
ST_SETSRID(bus_stops.geog::geography, 4326) AS stop_geom
FROM septa.bus_stops
CROSS JOIN LATERAL (
  SELECT ST_SETSRID(pwd_parcels.geog::geography, 4326) <-> ST_SETSRID(bus_stops.geog::geography, 4326) AS dist,
  pwd_parcels.address AS address
  FROM phl.pwd_parcels 
  ORDER BY dist DESC
  LIMIT 1
) AS near
ORDER BY dist DESC
LIMIT 1

SELECT parcels.address AS address, 
stops.stop_name AS stop_name, 
stops.distance AS distance
FROM phl.pwd_parcels AS parcels
CROSS JOIN LATERAl(
  SELECT stops.stop_name, 
  stops.geog, 
  ST_SETSRID(stops.geog :: geography, 4326) <-> ST_SETSRID(parcels.geog :: geography, 4326) AS distance
  FROM septa.bus_stops AS stops
  ORDER BY distance
  LIMIT 1 
) stops
ORDER BY distance DESC
LIMIT 1
