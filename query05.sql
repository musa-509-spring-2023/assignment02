WITH

bus_stops AS(
SELECT
	stop_id,
	stop_name,
	parent_station,
	wheelchair_boarding,
	geog
FROM septa.bus_stops
),

accessible_stations AS(
	SELECT * FROM bus_stops
	WHERE wheelchair_boarding = 1 
),

maybe_accessible_children AS(
	SELECT * FROM bus_stops
	WHERE wheelchair_boarding = 0 AND parent_station IS NOT NULL
),

accessible_children AS (
	SELECT 
		maybe_accessible_children.stop_id, 
		maybe_accessible_children.stop_name,
		maybe_accessible_children.parent_station,
		maybe_accessible_children.wheelchair_boarding,
		maybe_accessible_children.geog
	FROM maybe_accessible_children
	INNER JOIN septa.bus_stops AS stops ON stops.stop_id = maybe_accessible_children.parent_station
	WHERE stops.wheelchair_boarding = 1
), 

all_accessible_stops AS (
	SELECT * FROM accessible_stations UNION 
	SELECT * FROM accessible_children
),

aggregate_all AS(
	SELECT 
		nhoods.name,
		COUNT(stop_id) AS total_stops
	FROM bus_stops
	INNER JOIN azavea.neighborhoods as nhoods 
		ON ST_INTERSECTS(nhoods.geog, bus_stops.geog)
	GROUP BY nhoods.name	
),

accessible_aggregate AS(
	SELECT 
		nhood.name AS neighborhood_name,
		COUNT(stops.stop_name)/nhood.shape_area AS accessibility_metric,
		COUNT(stops.stop_name) AS num_bus_stops_accessible
	FROM all_accessible_stops as stops
	INNER JOIN azavea.neighborhoods as nhood
		ON ST_INTERSECTS(nhood.geog, stops.geog)
	GROUP BY neighborhood_name, nhood.shape_area
),

ranked_nhoods AS (
	SELECT 
		nhood.neighborhood_name::text,
		nhood.accessibility_metric,
		nhood.num_bus_stops_accessible::integer,
		(aggregate_all.total_stops - nhood.num_bus_stops_accessible)::integer AS num_bus_stops_inaccessible
	FROM accessible_aggregate AS nhood
	INNER JOIN aggregate_all ON aggregate_all.name = nhood.neighborhood_name
)

SELECT * from ranked_nhoods
ORDER BY accessibility_metric DESC