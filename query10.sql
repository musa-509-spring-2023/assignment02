/* 

    You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision

    stop_desc will include:
    distance to nearest panera cafe
    direction to nearest panera cafe

    in the format of:
    "Nearest panera cafe is <distance> miles to the <direction> at <address>."

        stops_closest_cafes.stop_id as stop_id,
        stops_closest_cafes.stop_name as stop_name,
        stops_closest_cafes.stop_lat as stop_lat,
        stops_closest_cafes.stop_lon as stop_lon,

*/

-- establish nearest cafe to each bus stop

/* 

    You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision

    dataset: Panera bread cafe locations in the greater philadelphia region, self-collected. Please find the csv in the respository, saved there just because it's so small (31 stores). Paneras are somewhat evenly distributed around the area, so no bus stop will have one that's enormously far.

    stop_desc will include:
    distance to nearest panera cafe
    direction to nearest panera cafe

    in the format of:
    "Nearest panera cafe is <distance> miles to the <direction> at <address>."

*/

-- establish nearest cafe to each bus stop

with stops_closest_cafes AS (
	SELECT
        stops.stop_id::integer as stop_id,
        stops.stop_name as stop_name,
        stops.stop_lat as stop_lat,
        stops.stop_lon as stop_lon,
        stops.geog,
        cafes.address AS cafe_address,
        round((st_distance(cafes.geog, stops.geog)/ 1609.34)::numeric, 2) AS cafe_distance,
		CASE
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) < 22.5 OR degrees(st_azimuth(cafes.geog, stops.geog)) > 337.5 THEN 'North'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 22.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 67.5 THEN 'Northeast'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 67.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 112.5 THEN 'East'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 112.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 157.5 THEN 'Southeast'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 157.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 202.5 THEN 'South'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 202.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 247.5 THEN 'Southwest'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 247.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 292.5 THEN 'West'
			WHEN degrees(st_azimuth(cafes.geog, stops.geog)) > 292.5 AND degrees(st_azimuth(cafes.geog, stops.geog)) < 337.5 THEN 'Northwest'
			ELSE degrees(st_azimuth(cafes.geog, stops.geog))::text
		END as cafe_direction
    FROM septa.bus_stops as stops
    CROSS JOIN LATERAL (
        SELECT
            cafes.cafe_address as address,
            cafes.geog,
            cafes.geog <-> stops.geog as dist
        FROM panera.cafes AS cafes
        ORDER BY dist
        LIMIT 1
    ) AS cafes
)

SELECT 
	stop_id AS stop_id,
	stop_name AS stop_name,
	'The nearest Panera Bread cafe is ' || cafe_distance || ' miles to the ' || cafe_direction || ' at ' || cafe_address || '.'	as stop_desc,
	stop_lon AS stop_lon,
	stop_lat AS stop_lat
FROM stops_closest_cafes
	