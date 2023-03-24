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
		COUNT(stops.stop_id) AS total_bus_stops,
		SUM(stops.wheelchair_boarding) AS wheelchair_boarding
	FROM nhood
	INNER JOIN stops ON st_intersects(stops.geog, nhood.geog)
	GROUP BY nhood.neighborhood)

SELECT 
	stops_nhood.neighborhood,
	stops_nhood.total_bus_stops AS prop_stops,
	AVG(stops_nhood.wheelchair_boarding) / SUM(stops_nhood.wheelchair_boarding) AS prop_wheelchair_boarding
FROM stops_nhood
GROUP BY stops_nhood.neighborhood, stops_nhood.total_bus_stops

-- bus stops is 8185
-- wheelchair boarding is 8483
-- Join bus stops to neighborhoods || select sum of stops and wheelchair boarding grouped by neighborhood

