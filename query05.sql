WITH t1 AS
(SELECT nb.name, ST_area(nb.geog)/1000000 area, COUNT(stops.stop_name) access_num
FROM phl.neighborhoods nb
LEFT JOIN septa.bus_stops stops
ON st_intersects(stops.geog, nb.geog)
GROUP BY 1,2
ORDER BY 2 DESC)

SELECT name, area, ROUND(access_num/area::decimal, 2) stops_per_sqkm
FROM t1