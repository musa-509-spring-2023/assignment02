 /* I rate the neighborhood accesibility by the 
 percentage of bus stops with wheel chair access to the total bus tops within the neighborhood.
 */
WITH 
joined AS (
    SELECT stops.stop_id, stops.geog, stops.wheelchair_boarding, hood.geog, hood.name
    FROM septa.bus_stops AS stops
    INNER JOIN azavea.neighborhoods AS hood
    ON st_intersects(st_setsrid(stops.geog::geography, 4326), st_setsrid(hood.geog::geography, 4326))
),

accessible_stops AS (
    SELECT name, count(*) as accessible
    FROM joined AS stops
    WHERE stops.wheelchair_boarding = 1
    GROUP BY name
),

total_stops AS (
    SELECT name, count(*) as total
    FROM joined AS stops
    GROUP BY name
)

SELECT
accessible_stops.name as neighborhood_name,
accessible_stops.accessible as num_bus_stops_accessible,
total_stops.total - accessible_stops.accessible as num_bus_stops_inaccessible,
accessible_stops.accessible/total_stops.total AS accessibility_metric
FROM accessible_stops
LEFT JOIN total_stops
on accessible_stops.name = total_stops.name
GROUP BY accessible_stops.name,accessible_stops.accessible,total_stops.total
ORDER BY accessibility_metric DESC
LIMIT 5