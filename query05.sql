/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use Azavea's neighborhood dataset from OpenDataPhilly along with an
appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation
for help. Use some creativity in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:


*/

/*  Accessibility metric:
    -The number of accessible bus stops (with presence of wheelchair boards),
    -The proximity between the bus stops and to health service center,
    including hospital (for example, Penn Medicine), schools and universities
    (for example, in this case, Upenn or Meyerson Hall).
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



