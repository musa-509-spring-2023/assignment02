/*

This file contains the SQL commands to prepare the database for your queries.
Before running this file, you should have created your database, created the
schemas (see below), and loaded your data into the database.

Creating your schemas
---------------------

You can create your schemas by running the following statements in PG Admin:

    create schema if not exists septa;
    create schema if not exists phl;
    create schema if not exists census;

Also, don't forget to enable PostGIS on your database:

    create extension if not exists postgis;

Loading your data
-----------------

After you've created the schemas, load your data into the database specified in
the assignment README.

Finally, you can run this file either by copying it all into PG Admin, or by
running the following command from the command line:

    psql -U postgres -d <YOUR_DATABASE_NAME> -f db_structure.sql

*/

-- add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa_bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa_bus_stops using gist
(geog);

/* query 01 */

alter table septa.bus_stops
drop column if exists geom;
alter table septa.bus_stops
add column geom geography(Point, 4326);
update septa.bus_stops set geom = ST_setSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;

alter table census.blockgroups_2020
drop column if exists geom;
alter table census.blockgroups_2020
add column geom geometry(MultiPolygon, 3857);
update census.blockgroups_2020 set geom = ST_Transform(geog::geometry, 3857);

/* query 03 */

alter table phl.pwd_parcels
drop column if exists geom;
alter table phl.pwd_parcels
add column geom geography(Point, 4326);
update phl.pwd_parcels set geom = ST_setSRID(ST_Centroid(geog), 4326)::geography;

/* query 04 */

alter table septa.bus_shapes
drop column if exists geom2;
alter table septa.bus_shapes
add column geom2 geography(Point, 4326);
update septa.bus_shapes set geom2 = ST_setSRID(geom, 4326)::geography;

/* query 05 */

alter table azavea.neighborhoods
drop column if exists geom;
alter table azavea.neighborhoods
add column geom geography(MultiPolygon, 4326);
update azavea.neighborhoods set geom = ST_setSRID(geog, 4326)::geography;

/* query 10 */

alter table septa.rail_stops
drop column if exists geom;
alter table septa.rail_stops
add column geom geography(Point, 4326);
update septa.rail_stops set geom = ST_setSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;
