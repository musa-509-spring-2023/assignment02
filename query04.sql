WITH length AS(
SELECT 
	shape_id, 
	ST_MakeLine(array_agg(
  		ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence)) as shape_geog,
  	ST_LENGTH(ST_MakeLine(array_agg(
  		ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))) as shape_length
FROM septa.bus_shapes
GROUP BY shape_id

)

SELECT DISTINCT 
	trips.trip_headsign,
	routes.route_short_name,
	length.shape_geog,
	length.shape_length
FROM length
JOIN septa.bus_trips AS trips ON length.shape_id = trips.shape_id
JOIN septa.bus_routes AS routes ON routes.route_id= trips.route_id
ORDER BY shape_length DESC
LIMIT 2