WITH t1 AS (SELECT
    nb.name,
    ST_AREA(nb.geog) / 1000000 AS area,
    COUNT(stops.stop_name) AS access_num
    FROM phl.neighborhoods AS nb
    LEFT JOIN septa.bus_stops AS stops
        ON ST_INTERSECTS(stops.geog, nb.geog)
    GROUP BY 1, 2
    ORDER BY 2 DESC
)

SELECT
    name,
    ROUND(access_num / area::decimal, 2) AS stops_per_sqkm,
    access_num AS num_bus_stops_accessible,
    13805 - access_num AS num_bus_stops_inaccessible
FROM t1
ORDER BY 2
LIMIT 5
