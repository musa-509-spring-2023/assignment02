WITH wheelchair_boarding_count AS (
    SELECT
        nbh.name,
        COUNT(stops.stop_id) AS count
    FROM azavea.neighborhoods AS nbh
    INNER JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog, nbh.geog)
    WHERE stops.wheelchair_boarding = 1
    GROUP BY nbh.name
),

accessibility_metric AS (
    SELECT
        nbh.name,
        COUNT(stops.stop_id)::FLOAT AS tot_stops,
        (w.count / COUNT(stops.stop_id)::FLOAT) * 0.8 + ((w.count / nbh.shape_area) * 10 ^ 5 / 0.79) * 0.2 AS metric
    FROM azavea.neighborhoods AS nbh
    INNER JOIN septa.bus_stops AS stops ON ST_INTERSECTS(stops.geog, nbh.geog)
    LEFT JOIN wheelchair_boarding_count AS w ON nbh.name = w.name
    GROUP BY nbh.name, w.count, nbh.shape_area
)

SELECT
    a.name AS neighborhood_name,
    a.metric AS accessibility_metric,
    w.count AS num_accessible_bus_stops,
    a.tot_stops - w.count AS num_inaccessible_bus_stops
FROM accessibility_metric AS a
INNER JOIN wheelchair_boarding_count AS w ON w.name = a.name
ORDER BY a.metric DESC
LIMIT 5
