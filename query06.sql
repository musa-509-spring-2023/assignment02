/*
What are the top five neighborhoods according to your accessibility metric?


*/


WITH wheelchair_accessible_stops AS (
  SELECT
    stop_id,
    ST_Distance_Sphere(
      ST_MakePoint(stop_lon, stop_lat),
      ST_MakePoint(-75.1949, 39.9522) -- Coordinates for Penn Medicine
    ) AS distance_to_penn_med,
    ST_Distance_Sphere(
      ST_MakePoint(stop_lon, stop_lat),
      ST_MakePoint(-75.1932, 39.9526) -- Coordinates for University of Pennsylvania
    ) AS distance_to_upenn
  FROM
    bus_stops
  WHERE
    wheelchair_boarding = 1
),
neighborhood_bus_stops AS (
  SELECT
    nbh.name AS neighborhood_name,
    bs.stop_id,
    CASE WHEN ws.stop_id IS NOT NULL THEN 'Accessible' ELSE 'Inaccessible' END AS wheelchair_accessibility
  FROM
    neighborhoods AS nbh
    JOIN LATERAL (
      SELECT
        stop_id,
        ST_Within(
          ST_MakePoint(bus_stops.stop_lon, bus_stops.stop_lat),
          nbh.geom
        ) AS within_neighborhood
      FROM
        bus_stops
    ) AS bs ON bs.within_neighborhood
    LEFT JOIN wheelchair_accessible_stops AS ws ON ws.stop_id = bs.stop_id
),
neighborhood_accessibility AS (
  SELECT
    neighborhood_name,
    COUNT(CASE WHEN wheelchair_accessibility = 'Accessible' THEN 1 END) AS num_bus_stops_accessible,
    COUNT(CASE WHEN wheelchair_accessibility = 'Inaccessible' THEN 1 END) AS num_bus_stops_inaccessible,
    SUM(1 / (1 + distance_to_penn_med) + 1 / (1 + distance_to_upenn)) AS accessibility_metric
  FROM
    neighborhood_bus_stops
  GROUP BY
    neighborhood_name
)
SELECT
  neighborhood_name,
  accessibility_metric,
  num_bus_stops_accessible,
  num_bus_stops_inaccessible
FROM
  neighborhood_accessibility
ORDER BY
  accessibility_metric DESC
LIMIT 5
