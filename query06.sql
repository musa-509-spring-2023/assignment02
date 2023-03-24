/*
What are the _top five_ neighborhoods according to your accessibility metric?

(
    neighborhood_name text,  -- The name of the neighborhood
    accessibility_metric ...,  -- Your accessibility metric value
    num_bus_stops_accessible integer,
    num_bus_stops_inaccessible integer
)


*/


WITH

-- calculate neighborhood pop

block_pop AS (
SELECT geoid, b.total, a.geog
FROM census.blockgroups_2020 AS a
INNER JOIN census.population_2020 AS b USING (geoid)
),

neigh_pop AS (
SELECT n.name, p.total, n.geog
FROM azavea.neighborhoods AS n
INNER JOIN block_pop AS p
	ON ST_within(ST_Transform(p.geog::geometry, 4236),  ST_Transform(n.geog::geometry, 4236))
ORDER BY n.name 
),

neight_pop_tot AS (
SELECT name, SUM(total) AS pop
FROM neigh_pop
GROUP BY name
),


-- bus_stop with wheelchair boarding

bus_wheelchair AS (
SELECT * 
FROM septa.bus_stops
WHERE wheelchair_boarding = '1'
),

-- generate intersections of 210m buffer with each neighborhood

step1 AS (
SELECT n.name, ST_Area(n.geog) AS n_area, 
ST_Area(ST_Intersection(ST_Buffer(st_setsrid(b.geog::geography, 4326), 210), st_setsrid(n.geog::geography, 4326))) AS inter_area,
ST_Intersection(ST_Buffer(st_setsrid(b.geog::geography, 4326), 210), st_setsrid(n.geog::geography, 4326)) AS inter_geog,
n.geog AS n_geog
FROM bus_wheelchair AS b
INNER JOIN azavea.neighborhoods AS n 
	ON st_dwithin(st_setsrid(b.geog::geography, 4326), st_setsrid(n.geog::geography, 4326), 210)
),

-- calculate total accessible area by neighborhood

step2 AS (
SELECT name, SUM(inter_area) AS access_area
FROM step1
GROUP BY name
),

-- join pop data

step3 AS (
SELECT *
FROM step2
INNER JOIN neight_pop_tot USING (name)
)

-- calculate accessibility_metric

SELECT DISTINCT name AS neighborhood_name, a.access_area/b.n_area*a.pop AS accessibility_metric, b.n_geog
FROM step3 AS a
INNER JOIN step1 AS b USING (name)
ORDER BY accessibility_metric DESC
LIMIT 5;



