/*You're tasked with giving more contextual information to rail 
stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, 
PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, 
build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets 
(must provide link to data used so it's reproducible), and other methods of describing the relationships. 
SQL's CASE statements may be helpful for some operations.*/
WITH rail AS(
SELECT *,
	ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326) AS geog
FROM septa.rail_stops
),

shapes AS(
	SELECT *,
	ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326) AS geog
FROM septa.bus_shapes)

SELECT DISTINCT s.stop_id, s.stop_name, s.stop_lon, s.stop_lat,ST_Azimuth(s.geog, rs.geog) AS bearing,
       CONCAT(
		   'This stop is located ',
		   ROUND(ST_Distance(s.geog, rs.geog)), ' meters ',
              CASE 
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN 0 AND 45 THEN 'NE'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN 45 AND 90 THEN 'E'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN 90 AND 135 THEN 'SE'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN 135 AND 180 THEN 'S'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN -180 AND -135 THEN 'S'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN -135 AND -90 THEN 'SW'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN -90 AND -45 THEN 'W'
                  WHEN ST_Azimuth(s.geog, rs.geog) BETWEEN -45 AND 0 THEN 'NW'
                  ELSE ''
              END, ' of ', rs.shape_id,
	   CASE
      -- Check if the stop is near a parcel
      WHEN ST_Distance(s.geog, b.geog) < 50 
        THEN CONCAT('near parcel ', p.parcelid)
      -- Check if the stop is in a block group
      WHEN ST_dwithin(st_setsrid(s.geog::geography,4326), st_setsrid(bg.geog::geography,4326),300) 
        THEN CONCAT('in block group', bg.namelsad)
      -- Check if the stop is in a neighborhood
      WHEN ST_dwithin(st_setsrid(s.geog::geography,4326), st_setsrid(n.geog::geography,4326),300) 
        THEN CONCAT('in neighborhood ', n.name)
	   WHEN EXISTS (
        SELECT *
		FROM census.population_2020 pop
		INNER JOIN census.blockgroups_2020 bg 
  		ON RIGHT(CAST(pop.geoid AS integer)::text, 12) = bg.geoid
      ) THEN CONCAT('the population', pop.total)
      ELSE ''
    END) AS stop_desc
FROM 
  rail s 
LEFT JOIN 
  septa.bus_stops b ON ST_Distance(s.geog, b.geog) < 300 
LEFT JOIN 
  phl.pwd_parcels p ON ST_Distance(s.geog, p.geog) < 300 
LEFT JOIN 
  census.blockgroups_2020 bg ON st_dwithin(st_setsrid(bg.geog::geography,4326), st_setsrid(s.geog::geography,4326), 300)
LEFT JOIN 
  azavea.neighborhoods n ON st_dwithin(st_setsrid(n.geog::geography,4326), st_setsrid(s.geog::geography,4326), 300) 
LEFT JOIN 
  shapes rs ON ST_Distance(s.geog, rs.geog) < 300 
WHERE 
  s.stop_desc IS NOT NULL
  limit 5;