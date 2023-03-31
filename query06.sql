alter table azavea.neighborhoods
alter column the_geog type geography
using ST_Transform(the_geog::geometry, 4269);

WITH
  neighborhoods AS (
    SELECT
      name,
      the_geog as geog
    FROM azavea.neighborhoods
  ),
  bus_stops AS (
    SELECT
      stop_id,
      stop_name,
      ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4269)::geography AS geog,
      wheelchair_boarding
    FROM septa.bus_stops
  ),
  neighborhood_bus_stops AS (
    SELECT
      neighborhoods.name AS neighborhood_name,
      COUNT(*) FILTER (WHERE bus_stops.wheelchair_boarding = 1) AS num_bus_stops_accessible,
      COUNT(*) FILTER (WHERE bus_stops.wheelchair_boarding = 0) AS num_bus_stops_inaccessible,
      ST_Area(neighborhoods.geog) AS area,
      ST_Union(bus_stops.geog::geometry) AS all_stops_geog
    FROM neighborhoods
    JOIN bus_stops ON ST_Intersects(neighborhoods.geog, bus_stops.geog)
    GROUP BY neighborhoods.name, neighborhoods.geog
  )
  
SELECT
  neighborhood_name,
  num_bus_stops_accessible / area AS accessibility_metric,
  num_bus_stops_accessible,
  num_bus_stops_inaccessible
FROM neighborhood_bus_stops
ORDER BY accessibility_metric DESC
LIMIT 5;
