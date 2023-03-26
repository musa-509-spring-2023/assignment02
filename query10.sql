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


WITH

rail_stop AS (SELECT stop_id, stop_name, stop_lon, stop_lat, ST_setsrid(ST_MakePoint(stop_lon, stop_lat), 4326) AS geog
FROM septa.rail_stops)

SELECT DISTINCT stop_id, stop_name, stop_lon, stop_lat, COUNT (pc.parcelid) OVER (PARTITION BY stop_id), r.geog
FROM rail_stop as r
INNER JOIN phl.pwd_parcels as pc
 ON st_dwithin(st_setsrid(pc.geog::geography, 4326), st_setsrid(r.geog::geography, 4326), 500)


