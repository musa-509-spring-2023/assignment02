SELECT
    aza.listname AS neighborhood_name,
    stops.wheelchair_boarding AS accessibility_metric,
    SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
    SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible
FROM azavea.neighborhoods AS aza, septa.bus_stops AS stops
WHERE ST_CONTAINS(aza.geog::geometry, stops.geog)
GROUP BY neighborhood_name, stops.wheelchair_boarding
ORDER BY num_bus_stops_accessible DESC, num_bus_stops_inaccessible ASC

-- I used wheelchair_boarding column as my metric to evaluate the accessibility. Bus stops with a value of 1 means the stop is wheelchair accessible, 2 means inaccessible
-- The top 5 stops are Overbrook 177 accessible stops, Olney 172 accessible stops, Somerton 165 accessible stops, Bustleton 158 accessible stops, Oxford Circle 139 accessible stops, 
