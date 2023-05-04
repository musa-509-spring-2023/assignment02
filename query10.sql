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
