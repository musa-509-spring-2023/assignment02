/*


You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. 
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string 
functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets 
(must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's
 CASE statements may be helpful for some operations.

Structure:

(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
)
As an example, your stop_desc for a station stop may be something like "37 meters NE of 1234 Market St" 
(that's only an example, feel free to be creative, silly, descriptive, etc.)

Tip when experimenting: Use subqueries to limit your query to just a few rows to keep query times faster. 
Once your query is giving you answers you want, scale it up. E.g., instead of FROM tablename, use FROM (SELECT * FROM tablename limit 10) as t.

*/
alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);

with 
    pop as(
        select b.total, a.geog
        from census.blockgroups_2020 as a 
	        inner join census.population_2020 as b
	        on '1500000US' || a.geoid = b.geoid),

    n1 as(
        select c.name, sum(pop.total) * 1.0 /c.shape_area as pop_density, c.geog,  c.shape_area as neighbor_area
        from azavea.neighborhoods as c
	        left join pop
	        on st_intersects(c.geog, pop.geog)
        group by c.name, c.shape_area , c.geog),

    ad as(
        select p.address, n1.geog, n1.name, n1.pop_density,  n1.neighbor_area
        from phl.pwd_parcels as p
        right join n1
        on st_contains(n1.geog::geometry, p.geog::geometry)
		)

select 
    r.stop_id,
    r.stop_name,
    case when ad.name || ad.address || ad. pop_density || ad.neighbor_area
			   is not null then ' Name：' || ad.name || 
			   ' Address：' || ad.address || 
			   ' Population density: ' || ad. pop_density || 
			   ' Neighborhood area: ' || ad.neighbor_area  end as stop_desc,
    r.stop_lon,
    r.stop_lat

from septa.rail_stops as r
left join ad
on st_contains(ST_SetSRID(ad.geog::geometry, 4326),ST_SetSRID(r.geog::geometry, 4326))