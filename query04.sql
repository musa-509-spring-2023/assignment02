WITH 
dist AS (
	SELECT shape_id, ST_MakeLine(array_agg(
	  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))::geography shape_geog,
	ST_LENGTH(ST_MakeLine(array_agg(
	  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))::geography) shape_length
	FROM septa.bus_shapes
	GROUP BY shape_id
),

trips AS (
	SELECT trip_id, route_id, trip_headsign, shape_geog, shape_length
	FROM septa.bus_trips trips
	LEFT JOIN dist
	ON trips.shape_id = dist.shape_id
),

routes AS (
	SELECT route_short_name, trip_headsign, shape_geog, shape_length,
	ROW_NUMBER() OVER(PARTITION BY route_short_name ORDER BY shape_length DESC) rk
	FROM septa.bus_routes routes
	LEFT JOIN trips
	ON routes.route_id = trips.route_id
)

SELECT route_short_name, trip_headsign, shape_geog, shape_length
FROM routes
WHERE rk = 1
ORDER BY shape_length DESC
LIMIT 2