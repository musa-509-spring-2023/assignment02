
-- distance to the closest wheelchair accessible stops for  each neighborhood
SELECT DISTINCT aza.listname AS neighborhood_name,
		st_distance(aza.geog, bss.geog) AS distance,
		aza.geog
	FROM azavea.neighborhoods AS aza 
	cross join lateral( 
		select bs.geog
		from septa.bus_stops AS bs
		where bs.wheelchair_boarding = 1
		order by aza.geog <-> bs.geog
		LIMIT 1 ) as bss
	order by distance DESC

-- number of wheelchair accessible stops in each neighborhood
WITH stops as (
	SELECT bs.geog
	FROM septa.bus_stops AS bs
	WHERE bs.wheelchair_boarding = 1
)

SELECT 
	aza.listname AS neighborhood_name,
	count(* ) AS num_wheelchair_stops
	
	FROM azavea.neighborhoods AS aza , stops
	WHERE ST_Contains(aza.geog:: geometry, stops.geog)
	GROUP BY neighborhood_name
	ORDER BY num_wheelchair_stops DESC
	