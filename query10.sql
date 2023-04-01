WITH Meyerson AS
(SELECT *
FROM phl.campus_buildings
WHERE address = '220-30 S 34TH ST' ),

t1 AS 
(SELECT stop_id, stop_name, stop_lon, stop_lat, ROUND(ST_Distance(Meyerson.geog, stops.geog)), 
CASE 
	WHEN ST_Azimuth(ST_Centroid(Meyerson.geog), stops.geog) < 90 THEN 'NE'
	WHEN ST_Azimuth(ST_Centroid(Meyerson.geog), stops.geog) BETWEEN 90 AND 180 THEN 'SE'
	WHEN ST_Azimuth(ST_Centroid(Meyerson.geog), stops.geog) BETWEEN 180 AND 270 THEN 'SW'
	ELSE 'NW'
END AS direction
FROM septa.rail_stops stops, Meyerson)

SELECT stop_id, stop_name, CONCAT (round, ' meters ', direction, ' of Meyerson Hall') stop_desc, stop_lon, stop_lat
FROM t1