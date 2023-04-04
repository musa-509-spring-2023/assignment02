/*
You're tasked with giving more contextual information to rail stops
to fill the stop_desc field in a GTFS feed. Using any of the data sets
above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
and PostgreSQL string functions, build a description (alias as stop_desc)
for each stop. Feel free to supplement with other datasets
(must provide link to data used so it's reproducible),
and other methods of describing the relationships.
SQL's CASE statements may be helpful for some operations.
*/

SELECT
    stop_id,
    stop_name,
    CASE
        WHEN stop_type = '1' THEN 'Rail Station'
        WHEN stop_type = '2' THEN 'Bus Station'
        WHEN stop_type = '3' THEN 'Ferry Terminal'
        ELSE 'Unknown Stop Type'
    END || ' - ' || ST_AsText(ST_Transform(geom, 4326)) AS stop_desc,
    stop_lon,
    stop_lat
FROM (
    SELECT
        stops.stop_id,
        stops.stop_name,
        stops.stop_type,
        ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326) AS geom,
        stops.stop_lon,
        stops.stop_lat,
        row_number() OVER (PARTITION BY stops.stop_id ORDER BY ST_Distance(stops.geom, parcels.geom) ASC) AS closest_parcels_rank
    FROM
        gtfs_stops stops
        CROSS JOIN LATERAL (
            SELECT geom FROM pwd_parcels WHERE ST_Contains(pwd_parcels.geom, ST_Transform(ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326), 2272))
        ) parcels
    WHERE
        ST_Distance(stops.geom, parcels.geom) <= 200  -- Consider only stops within 200 meters of a parcel
) stops_with_parcels
WHERE closest_parcels_rank = 1  -- Only keep stops closest to a parcel
ORDER BY stop_id;

