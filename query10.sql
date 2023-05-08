-- stop_desc: Description of the location that provides useful, quality information. Should not be a duplicate of stop_name.

--ideas: 'located in' azavea.neighborhoods.listname 'neighborhood'
--the "10th" stop on "route"?

--nearest neighbor takes too long so I'm stopping this
--
--WITH
--the_route AS (
--    SELECT
--        shapes.shape_id,
--        ST_MAKELINE(ARRAY_AGG(ST_SETSRID(
--            ST_MAKEPOINT(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326
--        )
--        ORDER BY shapes.shape_pt_sequence)) AS shape_geog
--    FROM septa.bus_shapes AS shapes
--    GROUP BY shapes.shape_id
--),
--
--joining AS (
--    SELECT
--        the_route.shape_id,
--        trips.trip_headsign,
--		trips.route_id,
--        the_route.shape_geog
--    FROM the_route
--    INNER JOIN septa.bus_trips AS trips USING (shape_id)
--), 
--
--more_joining AS (
--	SELECT DISTINCT
--    	routes.route_long_name AS name,
--    	joining.shape_geog
--	FROM septa.bus_routes AS routes 
--	INNER JOIN joining
--		ON joining.route_id = routes.route_id
--), 
--
--aggregate_geog AS (
--	SELECT
--    	name,
--    	ST_UNION(shape_geog) AS all_shapes
--	FROM more_joining
--	GROUP BY name
--)
--
--SELECT DISTINCT
--	stops.stop_name,
--	aggregate_geog.name AS closest_route_name
--FROM aggregate_geog
--INNER JOIN septa.bus_stops AS stops
--	ON ST_INTERSECTS(stops.geog, aggregate_geog.all_shapes) 

SELECT 
    stops.stop_id,
    stops.stop_name,
    CONCAT('Located in ', REPLACE(LOWER(nhoods.name),'_',' '), ' neighborhood') AS stop_desc,
    stops.stop_lon,
    stops.stop_lat
FROM septa.bus_stops AS stops
INNER JOIN azavea.neighborhoods as nhoods 
    ON ST_INTERSECTS(nhoods.geog, stops.geog)