/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.
*/

/*
Descriptions : 
To assess the accessibility of public transportation for wheelchair users, I first determined that the average speed of a normal wheelchair is 0.7 m/s. I then established a criterion that if the distance between a station and a home takes more than 5 minutes to traverse at that speed, it cannot be considered accessible. To create a buffer zone that accounts for this criterion, I multiplied the speed by 60 (to convert from m/s to m/min) and by 5 (to cover a 5-minute distance), resulting in a buffer of 210 m.

I designated this buffer zone as the "transit accessible zone for wheelchairs" and divided it by the entire neighborhood area to obtain the "bus stop accessibility for wheelchairs index", which represents the proportion of the neighborhood that falls within the transit accessible zone for wheelchairs."

*/

-- Create bus station goeg

WITH

-- Create 210m buffer from each bus station goeg

buffer AS (
SELECT ST_Buffer(geog, 210) AS buffer_geog
FROM septa.bus_stops 
)

-- neighborhood 

SELECT ST_Area(ST_Intersection(ST_Transform(buffer.buffer_geog::geometry, 4326), ST_Transform(azavea.neighborhoods.geog::geometry, 4326))) as intersected_area
FROM buffer, azavea.neighborhoods;
