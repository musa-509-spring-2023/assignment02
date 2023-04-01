WITH t1 AS
(SELECT nb.name, ST_area(nb.geog)/1000000 area, COUNT(stops.stop_name) access_num
FROM phl.neighborhoods nb
LEFT JOIN septa.bus_stops stops
ON st_intersects(stops.geog, nb.geog)
GROUP BY 1,2
ORDER BY 2 DESC)

SELECT name, ROUND(access_num/area::decimal, 2) stops_per_sqkm, access_num num_bus_stops_accessible, 13805-access_num num_bus_stops_inaccessible
FROM t1
ORDER BY 2 DESC
LIMIT 5