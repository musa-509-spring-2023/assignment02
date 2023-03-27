/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
and PostgreSQL string functions, build a description (alias as stop_desc) for each stop.
Feel free to supplement with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

Structure:

(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
)
As an example, your stop_desc for a station stop may be something like
"37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

Tip when experimenting: Use subqueries to limit your query to just a few rows to keep query times faster.
Once your query is giving you answers you want, scale it up. E.g.,
instead of FROM tablename, use FROM (SELECT * FROM tablename limit 10) as t.

My description provides the number of meters to the rail stop's nearest wheelchair-accessible bus stop.
*/

-- explain 
with rail as (
    select
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        st_setsrid(st_makepoint(stop_lon, stop_lat), 4326) as geog
    from septa.rail_stops
),

closest_accessible_stops as (
    select
        bus.geog,
        bus.wheelchair_boarding,
        bus.stop_id as bus_stop_id,
        (bus.geog <-> st_setsrid(rail.geog::geography, 4326)::geography) as min_distance
    from septa.bus_stops as bus
    where bus.wheelchair_boarding = 1
    order by min_distance asc
    limit 1
),

rail_stop_neighbors as (
    select 
        rail.stop_id as rail_stop_id,
        rail.stop_name as rail_stop_name,
        rail.geog,
        rail.stop_lon,
        rail.stop_lat,
        min_distance
    from rail
    cross join lateral closest_accessible_stops
    order by min_distance dec
)

select
rail_stop_id::integer as stop_id,
rail_stop_name::text as stop_name,
round(min_distance) || ' meters to nearest wheelchair-accessible bus stop'::text as stop_desc,
stop_lon::double precision,
stop_lat::double precision
from rail_stop_neighbors
order by stop_name
limit 10;
