/*
What are the _bottom five_ neighborhoods according to your accessibility metric?

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
    SELECT
        geoid,
        b.total,
        a.geog
    FROM census.blockgroups_2020 AS a
    INNER JOIN census.population_2020 AS b USING (geoid)
),

neigh_pop AS (
    SELECT
        n.name,
        p.total,
        n.geog
    FROM azavea.neighborhoods AS n
    INNER JOIN block_pop AS p
        ON ST_WITHIN(ST_TRANSFORM(p.geog::geometry, 4236), ST_TRANSFORM(n.geog::geometry, 4236))
),

neight_pop_tot AS (
    SELECT
        name,
        SUM(total) AS pop
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
    SELECT
        n.name,
        n.geog AS n_geog,
        ST_AREA(n.geog) AS n_area,
        ST_INTERSECTION(ST_BUFFER(b.geog::geography, 210), n.geog::geography) AS inter_geog,
        ST_AREA(ST_INTERSECTION(ST_BUFFER(b.geog::geography, 210), n.geog::geography)) AS inter_area
    FROM bus_wheelchair AS b
    INNER JOIN azavea.neighborhoods AS n
        ON ST_DWITHIN(b.geog::geography, n.geog::geography, 210)
),

-- calculate total accessible area by neighborhood
step2 AS (
    SELECT
        name,
        SUM(inter_area) AS access_area
    FROM step1
    GROUP BY name
),

-- join pop data
step3 AS (
    SELECT
        step2.name,
        step2.access_area,
        neight_pop_tot.pop
    FROM step2
    INNER JOIN neight_pop_tot USING (name)
)

-- calculate accessibility_metric
SELECT DISTINCT
    step1.n_geog,
    step3.name AS neighborhood_name,
    step3.access_area / step1.n_area * step3.pop AS accessibility_metric
FROM step3
INNER JOIN step1 USING (name)
ORDER BY accessibility_metric
LIMIT 5;




