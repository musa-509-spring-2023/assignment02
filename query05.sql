-- Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

-- NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

-- Discuss your accessibility metric and how you arrived at it below:

-- Description:

-- I use two datsets 'septa.bus_stops' and 'azavea.neighborhoods' to calculate the wheelchair accessibility.
-- First, select wheelchair_boarding, stop_name, geog from 'septa.bus_stops' table. The CASE statement is used to create a column named wc that indicates if the stop is wheelchair accessible, with the values YES and NO.
-- THen, select geog, neighborhood_name and area from 'azavea.neighborhoods' table.
-- The third CTE 'neighborhood_wheelchair_count' joins the joins the wc_stop and nh_area CTEs and groups by neighborhood name and area. It counts the number of wheelchair accessible (wc_yes) and inaccessible (wc_no) bus stops for each neighborhood.
-- Finally, the main query selects the neighborhood_name, calculates the accessibility_metric, which is the number of wheelchair accessible bus stops per 10,000 square meters, rounds the result to two decimal places, and returns the number of num_bus_stops_accessible and num_bus_stops_inaccessible.

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
ORDER BY accessibility_metric DESC;
