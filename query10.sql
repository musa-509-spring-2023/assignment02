WITH  meyerson AS (
SELECT
	stop_id,
	stop_name,
	(ST_Distance(rail.geog::geography, ST_SetSRID(ST_MAKEPOINT(-75.19257636686456, 39.95228837794948)::geography,4326)) * 0.000621371) AS stop_desc,
	stop_lon,
	stop_lat
FROM septa.rail_stops AS rail)

SELECT 
	stop_id,
	stop_name,
	CONCAT('This stop is ', ROUND(stop_desc::integer, 0), ' miles away from pain (Meyerson Hall).') AS stop_desc,
	stop_lon,
	stop_lat
FROM meyerson
