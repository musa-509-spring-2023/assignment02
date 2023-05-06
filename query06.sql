/*What are the top five neighborhoods according to your accessibility metric?*/
WITH wheelchair_stops AS (
  SELECT DISTINCT 
	s.stop_id, 
	n.name
  FROM septa.bus_stops AS s
  JOIN azavea.neighborhoods AS n ON ST_Intersects(s.geog, n.geog)
  WHERE s.wheelchair_boarding = '1'
),

area AS(
	SELECT n.name,
	COUNT(w.stop_id)*100000/(n.shape_area*0.787) AS ratio_area
	FROM azavea.neighborhoods AS n
	JOIN wheelchair_stops AS w ON n.name = w.name
	GROUP BY n.name,n.shape_area
	ORDER BY ratio_area
),

ratios AS (
SELECT n.name, COUNT(w.stop_id)*0.7 / COUNT(s.stop_id)+a.ratio_area*0.3::float AS ratio
	FROM azavea.neighborhoods AS n
	JOIN septa.bus_stops AS s ON ST_Intersects(s.geog, n.geog)
	JOIN area AS a ON a.name = n.name
	LEFT JOIN wheelchair_stops AS w ON s.stop_id = w.stop_id
  GROUP BY n.name,a.ratio_area
)

SELECT 
r.name AS neighborhood_name, 
CASE 
	WHEN r.ratio>=0.8 THEN 'good'
	WHEN r.ratio>=0.5 THEN 'normal'
	WHEN r.ratio>=0 THEN 'bad'
ELSE 'unknown'
END AS accessibility_metric,
COUNT(w.stop_id)::integer AS num_bus_stops_accessible,
(COUNT(s.stop_id)-COUNT(w.stop_id))::integer AS num_bus_stops_inaccessible
FROM ratios AS r
JOIN azavea.neighborhoods AS n ON r.name = n.name
JOIN septa.bus_stops AS s ON ST_Intersects(s.geog, n.geog)
LEFT JOIN wheelchair_stops AS w ON s.stop_id = w.stop_id
GROUP BY r.name,r.ratio
ORDER BY r.ratio DESC
LIMIT 5;