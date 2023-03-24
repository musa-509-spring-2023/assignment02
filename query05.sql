/* 
*/
WITH 
stops AS (
	SELECT
		stop.stop_id,
		stop.wheelchair_boarding,
		ST_transform(stop.geog::geometry, 2272) AS geog
	FROM septa.bus_stops AS stop),

nhood AS (
	SELECT 
		nhood."MAPNAME" AS neighborhood,
		ST_transform(nhood.geometry, 2272) AS geog
	FROM azavea.neighborhoods AS nhood),

stops_nhood AS (
	SELECT
		nhood.neighborhood,
		stops.stop_id AS stop_id,
		stops.wheelchair_boarding AS wheelchair_boarding
	FROM nhood
	INNER JOIN stops ON st_intersects(stops.geog, nhood.geog)
	GROUP BY nhood.neighborhood, stops.stop_id, stops.wheelchair_boarding)

SELECT 
	stops_nhood.neighborhood,
	count(stops_nhood.stop_id) AS number_of_stops,
	COUNT(stops_nhood.wheelchair_boarding)  AS number_of_wb
FROM stops_nhood
GROUP BY stops_nhood.neighborhood

WITH
accessible AS (
	SELECT 
		COUNT(wheelchair_boarding) AS is_accessible,
		ST_transform(geog::geometry, 2272) AS geog
	FROM septa.bus_stops
	WHERE wheelchair_boarding = 1
	GROUP BY geog),
	
inaccessible AS (
	SELECT 
		COUNT(wheelchair_boarding) AS not_accessible,
		ST_transform(geog::geometry, 2272) AS geog
	FROM septa.bus_stops
	WHERE wheelchair_boarding = 2
	GROUP BY geog)

SELECT * from inaccessible
-- SELECT * FROM septa.bus_stops
-- bus stops is 8185
-- wheelchair boarding is 8483
-- Join bus stops to neighborhoods || select sum of stops and wheelchair boarding grouped by neighborhood

