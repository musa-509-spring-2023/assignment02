/*Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.*/
WITH length AS(
	SELECT 
		s.shape_id AS shape_id,
		ST_MakeLine(array_agg(ST_SetSRID(ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat),4326) ORDER BY s.shape_pt_sequence)) AS shape_geog,
		ST_Length(ST_MakeLine(array_agg(ST_SetSRID(ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat),4326) ORDER BY s.shape_pt_sequence))) AS shape_length
	FROM septa.bus_shapes AS s
	GROUP BY s.shape_id)
SELECT DISTINCT
  r.route_short_name, 
  t.trip_headsign,
  l.shape_length,
  l.shape_geog
  FROM length AS l
  JOIN septa.bus_trips AS t ON l.shape_id = t.shape_id
  JOIN septa.bus_routes AS r ON t.route_id = r.route_id
  ORDER BY shape_length DESC
  LIMIT 2