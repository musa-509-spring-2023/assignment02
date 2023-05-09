/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.

    **Structure:**
    ```sql
    (
        stop_id integer,
        stop_name text,
        stop_desc text,
        stop_lon double precision,
        stop_lat double precision
    )
    ```

   As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

   >**Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.
   */


SELECT DISTINCT stop_id, stop_name,
    'There are ''' || COUNT(pc.parcelid) OVER (PARTITION BY stop_id) || ' parcels'' within ''500 meters'' of the station and average distance between the station and ''' || COUNT(pc.parcelid) OVER (PARTITION BY stop_id) || ' parcels'' is ''' || ROUND(AVG(pc.geog <-> r.geog) OVER (PARTITION BY stop_id)) || 'm''' AS stop_desc,
    stop_lon, stop_lat
FROM septa.rail_stops AS r
INNER JOIN phl.pwd_parcels AS pc
    ON ST_DWITHIN(pc.geog::geography, r.geog::geography, 500);
