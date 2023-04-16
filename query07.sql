/*
What are the bottom five neighborhoods according to your accessibility metric?
*/


WITH accessible_stops AS (
  SELECT
    bs.stop_id,
    bs.stop_name,
    bs.wheelchair_boarding,
    br.route_short_name,
    ST_SetSRID(ST_Point(bs.stop_lon, bs.stop_lat), 4326) AS stop_geom
  FROM
    septa.bus_stops bs
    JOIN septa.bus_routes br ON br.route_id = br.route_id
  WHERE
    bs.wheelchair_boarding = 1
),
stops_neighborhoods AS (
  SELECT
    accessible_stops.*,
    nbh.name AS neighborhood_name
  FROM
    accessible_stops
    JOIN azavea.neighborhoods nbh ON ST_Contains(nbh.geometry, accessible_stops.stop_geom)
),
neighborhood_ranking AS (
  SELECT
    neighborhood_name,
    COUNT(*) AS accessible_stop_count,
    COUNT(CASE WHEN wheelchair_boarding = 1 THEN 1 END) AS num_bus_stops_accessible,
    COUNT(CASE WHEN wheelchair_boarding = 0 THEN 1 END) AS num_bus_stops_inaccessible
  FROM
    stops_neighborhoods
  GROUP BY
    neighborhood_name
  ORDER BY
    accessible_stop_count ASC
)
SELECT
  neighborhood_name,
  accessible_stop_count AS accessibility_metric,
  num_bus_stops_accessible,
  num_bus_stops_inaccessible
FROM
  neighborhood_ranking
LIMIT 5
