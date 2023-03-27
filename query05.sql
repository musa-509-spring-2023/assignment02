WITH wheelchair_boarding AS(
	SELECT
		nbh.name,
        COUNT(stops.stop_id) AS count
    FROM azavea.neighborhoods AS nbh
    JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog,nbh.geog)
	WHERE stops.wheelchair_boarding = 1
	GROUP BY name
),
ratio AS(
	SELECT
		nbh.name,
		COUNT(stops.stop_id)::FLOAT AS tot_stops,
        w.count / COUNT(stops.stop_id)::FLOAT AS stop_ratio, 
		(w.count / nbh.shape_area)*10^5/0.787 AS area_ratio
  	FROM azavea.neighborhoods AS nbh
    JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog,nbh.geog)
	LEFT JOIN wheelchair_boarding AS w ON nbh.name = w.name
	GROUP BY nbh.name, w.count, nbh.shape_area
)


SELECT 
	r.name AS neighborhood_name,
	r.stop_ratio*0.7+r.area_ratio*0.3 AS accessibility_metric,
	w.count AS num_bus_stops_accessible,
	r.tot_stops - w.count AS num_bus_stops_inaccessible
FROM ratio AS r
JOIN wheelchair_boarding AS w ON w.name = r.name
ORDER BY accessibility_metric DESC





	