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
		stops.wheelchair_boarding AS is_accessible
	FROM stops
	INNER JOIN nhood ON st_intersects(stops.geog, nhood.geog)
	WHERE wheelchair_boarding = 1),
	
stops_nhood_no AS (
	SELECT
		nhood.neighborhood,
		stops.wheelchair_boarding AS not_accessible
	FROM stops
	INNER JOIN nhood ON st_intersects(stops.geog, nhood.geog)
	WHERE wheelchair_boarding = 2 OR wheelchair_boarding = 0),
	
final_df AS (
	SELECT
		yes_access.neighborhood,
		yes_access.is_accessible AS num_bus_stops_accessible,
		no_access.not_accessible AS num_bus_stops_inaccessible
	FROM stops_nhood_yes AS yes_access
	INNER JOIN stops_nhood_no AS no_access ON no_access.neighborhood = yes_access.neighborhood
	GROUP BY yes_access.neighborhood, yes_access.is_accessible, no_access.not_accessible)

SELECT * from stops_nhood_no

ccc
