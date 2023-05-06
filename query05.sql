WITH
joined AS (
    SELECT
        stops.stop_id,
        stops.geog,
        stops.wheelchair_boarding,
        hood.geog,
        hood.name
    FROM septa.bus_stops AS stops
    INNER JOIN azavea.neighborhoods AS hood
        ON st_intersects(st_setsrid(stops.geog::geography, 4326), st_setsrid(hood.geog::geography, 4326))
),

accessible_stops AS (
    SELECT
        stops.name,
        stops.wheelchair_boarding,
        count(*) AS accessible
    FROM joined AS stops
    WHERE stops.wheelchair_boarding = 1
    GROUP BY stops.name
),

total_stops AS (
    SELECT
        stops.name,
        count(*) AS total
    FROM joined AS stops
    GROUP BY stops.name
)

SELECT
    accessible_stops.name AS neighborhood_name,
    accessible_stops.accessible AS num_bus_stops_accessible,
    total_stops.total - accessible_stops.accessible AS num_bus_stops_inaccessible,
    accessible_stops.accessible / total_stops.total AS accessibility_metric
FROM accessible_stops
LEFT JOIN total_stops
    ON accessible_stops.name = total_stops.name
GROUP BY accessible_stops.name, accessible_stops.accessible, total_stops.total
ORDER BY accessibility_metric DESC
LIMIT 5
