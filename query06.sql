/*
What are the _top five_ neighborhoods according to your accessibility metric?
*/

/*same code as the last question*/
WITH 
n_stops AS (
	SELECT
    neighborhood.name,
    /*transform the area*/
    ST_AREA(neighborhood.geog) / 1000000 AS area,
    /*count the number of bus stops as a varibale in caculating the rate*/
    COUNT(stops.stop_name) AS access_num
    FROM azavea.neighborhoods AS neighborhood
    /*spatial join*/
    LEFT JOIN septa.bus_stops AS stops
        ON ST_INTERSECTS(stops.geog, neighborhood.geog)
    GROUP BY 1, 2
    ORDER BY 2 DESC
)

SELECT
    name,
    area,
    ROUND(access_num / area::decimal, 2) AS stops_per_sqkm
FROM n_stops
ORDER BY stops_per_sqkm DESC
LIMIT 5;