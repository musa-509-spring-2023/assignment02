SELECT
    stops.stop_id,
    stops.stop_name,
    CONCAT('Located in ', REPLACE(LOWER(nhoods.name), '_', ' '), ' neighborhood') AS stop_desc,
    stops.stop_lon,
    stops.stop_lat
FROM septa.bus_stops AS stops
INNER JOIN azavea.neighborhoods AS nhoods
    ON ST_INTERSECTS(nhoods.geog, stops.geog)
