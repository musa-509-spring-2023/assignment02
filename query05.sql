/* 
*/
WITH 
stops AS (
	SELECT
		stop.wheelchair_boarding AS wheelchair_boarding,
		ST_transform(stop.geog::geometry, 2272) AS geog
	FROM septa.bus_stops AS stop
	GROUP BY stop.wheelchair_boarding, geog),

nhood AS (
	SELECT 
		nhood."MAPNAME" AS neighborhood,
		ST_transform(nhood.geometry, 2272) AS geog
	FROM azavea.neighborhoods AS nhood),

stops_nhood_yes AS (
	SELECT
		nhood.neighborhood,
		SUM(stops.wheelchair_boarding) AS is_accessible
	FROM stops
	INNER JOIN nhood ON st_intersects(stops.geog, nhood.geog)
	WHERE wheelchair_boarding = 1
	GROUP BY nhood.neighborhood),
	
stops_nhood_no AS (
	SELECT
		nhood.neighborhood,
		CASE
			WHEN stops.wheelchair_boarding = 2 THEN COUNT(stops.wheelchair_boarding)
			WHEN stops.wheelchair_boarding = 0 THEN COUNT(stops.wheelchair_boarding)
			ELSE 0 END AS not_accessible
	FROM stops
	INNER JOIN nhood ON st_intersects(stops.geog, nhood.geog)
	GROUP BY nhood.neighborhood, stops.wheelchair_boarding),

all_stops AS (
	SELECT
		yes_stop.neighborhood AS neighborhood,
		yes_stop.is_accessible - no_stop.not_accessible AS metric,
		yes_stop.is_accessible AS num_accessible_stops,
		no_stop.not_accessible AS num_inaccessible_stops
	FROM stops_nhood_yes AS yes_stop
	INNER JOIN stops_nhood_no AS no_stop ON no_stop.neighborhood = yes_stop.neighborhood
	GROUP BY yes_stop.neighborhood, yes_stop.is_accessible, no_stop.not_accessible)


SELECT 
	neighborhood,
	metric,
	num_accessible_stops,
	num_inaccessible_stops
FROM all_stops
ORDER BY metric DESC


