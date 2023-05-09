SELECT
    aza.listname AS neighborhood_name,
    stops.wheelchair_boarding AS accessibility_metric,
    SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
    SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible
FROM azavea.neighborhoods AS aza, septa.bus_stops AS stops
WHERE ST_CONTAINS(aza.geog::geometry, stops.geog)
GROUP BY neighborhood_name, stops.wheelchair_boarding
ORDER BY num_bus_stops_accessible ASC, num_bus_stops_inaccessible DESC
LIMIT 5

    -- The bottom 5 stops are Paschall 38 inaccessible stops, Kingsessing 31 inaccessible stops, Southwest Schuylkill 30 inaccessible stops, Elmwood 30 inaccessible stops, Overbrook 23 inaccessible stops
