/*
What are the bottom five neighborhoods according to your accessibility metric?
*/

WITH wheelchair_accessible_stops AS (
  SELECT DISTINCT ON (stop_id) stop_id, stop_name, stop_lat, stop_lon
  FROM bus_stops
  WHERE wheelchair_boarding = '1'
),
stops_with_distance_to_penn AS (
  SELECT
    stop_id,
    stop_name,
    stop_lat,
    stop_lon,
    ST_DistanceSphere(
      ST_MakePoint(stop_lon, stop_lat),
      ST_MakePoint(-75.1949, 39.9526) -- coordinates for Penn Medicine
    ) AS distance_to_penn
  FROM bus_stops
),
neighborhood_accessibility AS (
  SELECT
    n.name AS neighborhood_name,
    COUNT(DISTINCT CASE WHEN s.stop_id IS NOT NULL THEN s.stop_id END) AS num_bus_stops_accessible,
    COUNT(DISTINCT CASE WHEN s.stop_id IS NULL THEN stops_with_distance_to_penn.stop_id END) AS num_bus_stops_inaccessible,
    COUNT(DISTINCT s.stop_id) AS num_bus_stops_total,
    SUM(CASE WHEN s.stop_id IS NOT NULL THEN 1 ELSE 0 END) AS num_accessible_stops_near_penn,
    SUM(CASE WHEN s.stop_id IS NULL THEN 1 ELSE 0 END) AS num_inaccessible_stops_near_penn,
    COUNT(DISTINCT s.stop_id) / NULLIF(COUNT(DISTINCT CASE WHEN s.stop_id IS NOT NULL THEN s.stop_id END), 0) AS accessibility_metric
  FROM neighborhoods n
  LEFT JOIN bus_stop_neighborhoods bsn ON n.name = bsn.neighborhood_name
  LEFT JOIN wheelchair_accessible_stops s ON bsn.stop_id = s.stop_id
  LEFT JOIN stops_with_distance_to_penn ON stops_with_distance_to_penn.stop_id = s.stop_id
  WHERE n.city = 'Philadelphia'
  GROUP BY n.name
  ORDER BY accessibility_metric ASC
  LIMIT 5
)

SELECT
  neighborhood_name,
  accessibility_metric,
  num_bus_stops_accessible,
  num_bus_stops_inaccessible
FROM neighborhood_accessibility;

