-- Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

-- NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

-- Discuss your accessibility metric and how you arrived at it below:

-- Description:


WITH
-- calculate neighborhood pop
block_pop AS (
    SELECT
        geoid,
        b.total,
        a.geog
    FROM census.blockgroups_2020 AS a
    INNER JOIN census.population_2020 AS b USING (geoid)
),

neigh_pop AS (
    SELECT
        n.name,
        p.total,
        n.geog
    FROM azavea.neighborhoods AS n
    INNER JOIN block_pop AS p
        ON ST_WITHIN(ST_TRANSFORM(p.geog::geometry, 4236), ST_TRANSFORM(n.geog::geometry, 4236))
),

neight_pop_tot AS (
    SELECT
        name,
        SUM(total) AS pop
    FROM neigh_pop
    GROUP BY name
),

-- bus_stop with wheelchair boarding
bus_wheelchair AS (
    SELECT *
    FROM septa.bus_stops
    WHERE wheelchair_boarding = '1'
),

WITH wheelchair_stops AS (
  SELECT * FROM septa.bus_stops WHERE wheelchair_boarding = '1'
),
neighborhoods AS (
  SELECT name, geog, ST_AREA(geog::geography) AS area FROM azavea.neighborhoods
),
wheelchair_stops_buffered AS (
  SELECT ST_INTERSECTION(n.geog, ST_BUFFER(s.geog::geography, 210)) AS intersection_geog, s.stop_id, s.stop_name
  FROM wheelchair_stops AS s, neighborhoods AS n
  WHERE ST_DWithin(s.geog::geography, n.geog::geography, 210)
),
neighborhoods_access AS (
  SELECT n.name, SUM(ST_AREA(ws.intersection_geog::geography)) AS access_area
  FROM neighborhoods AS n, wheelchair_stops_buffered AS ws
  WHERE ST_Intersects(ws.intersection_geog::geography, n.geog::geography)
  GROUP BY n.name
),
neighborhoods_pop AS (
  SELECT n.name, SUM(p.total) AS pop
  FROM neighborhoods AS n, census.population_2020 AS p
  WHERE ST_Within(p.geog::geometry, n.geog::geometry)
  GROUP BY n.name
),
neighborhoods_combined AS (
  SELECT n.name, n.geog, n.area, na.access_area, np.pop
  FROM neighborhoods AS n, neighborhoods_access AS na, neighborhoods_pop AS np
  WHERE n.name = na.name AND n.name = np.name
),
accessibility AS (
  SELECT nc.name, (nc.access_area / nc.area) * nc.pop AS accessibility_metric, nc.geog
  FROM neighborhoods_combined AS nc
  ORDER BY accessibility_metric DESC
  LIMIT 5
)
SELECT accessibility.name AS neighborhood_name, accessibility.accessibility_metric, accessibility.geog AS neighborhood_geog
FROM accessibility
