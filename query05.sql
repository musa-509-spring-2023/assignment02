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
    COUNT(*) AS accessible_stop_count
  FROM
    stops_neighborhoods
  GROUP BY
    neighborhood_name
  ORDER BY
    accessible_stop_count DESC
)
SELECT * FROM neighborhood_ranking


