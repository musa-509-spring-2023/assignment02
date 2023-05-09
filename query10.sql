-- You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
-- Calculate the nearest parcel distance of each station as 'stop_desc'.

SELECT DISTINCT
    r.stop_id,
    r.stop_name,
    CONCAT('The nearest parcel is in ', CAST(MIN(pc.geog::geography <-> r.geog::geography) AS numeric(10,2)), ' meters') AS stop_desc,
    r.stop_lon,
    r.stop_lat
FROM septa.rail_stops AS r
INNER JOIN phl.pwd_parcels AS pc
    ON ST_DWithin(pc.geog::geography, r.geog::geography, 500)
GROUP BY r.stop_id, r.stop_name, r.stop_lon, r.stop_lat;