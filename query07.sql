-- What are the bottom five neighborhoods according to your accessibility metric?

-- The bottom five neighborhoods of accessibility is Bartram Village, Airport, West Torresdale, Industrial and Navy Yard.

WITH 
wc_stop AS (
    SELECT
        wheelchair_boarding,
        stop_name,
        geog,
        CASE
            WHEN wheelchair_boarding = 1 THEN 'YES'
            WHEN wheelchair_boarding = 2 THEN 'NO'
        END AS wc
    FROM septa.bus_stops
),

nh_area AS (
    SELECT
        geog,
        listname AS neighborhood_name,
        shape_area AS area
    FROM azavea.neighborhoods
),

neighborhood_wheelchair_count AS (
    SELECT
        nh_area.neighborhood_name,
        nh_area.area,
        COUNT(CASE wc_stop.wc WHEN 'YES' THEN 1 END) AS wc_yes,
        COUNT(CASE wc_stop.wc WHEN 'NO' THEN 1 END) AS wc_no
    FROM wc_stop
    INNER JOIN nh_area
        ON ST_Intersects(wc_stop.geog, nh_area.geog)
    GROUP BY nh_area.neighborhood_name, nh_area.area
)

SELECT
    neighborhood_name,
	CAST(wc_yes / area * 100000 AS numeric(10, 2)) AS accessibility_metric,
    wc_yes AS num_bus_stops_accessible,
    wc_no AS num_bus_stops_inaccessible
FROM neighborhood_wheelchair_count
ORDER BY accessibility_metric
LIMIT 5;

