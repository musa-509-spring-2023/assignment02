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

--- BUS STOPS ---

-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist(geog);

-- Add index to geom column of septa.bus_stops
create index if not exists septa_bus_stops__geom__dix
on septa.bus_stops using gist(geom);

-- Add a column for 

--- WATER DEPT PARCELS---

-- Add a column to the phl.pwd_parcels table to store the geometry of each parcel
alter table phl.pwd_parcels
add column if not exists geom geometry;

update phl.pwd_parcels
set geom = st_transform(geog::geometry, 4326);

-- Create index on the geom column.
create index if not exists phl_pwd_parcels__geom__idx
on septa.bus_stops using gist(geom);

-- Add a column to the phl.pwd_parcels table to store the centroid of each parcel
alter table phl.pwd_parcels
add column if not exists pt_geog geography;

update phl.pwd_parcels
set pt_geog = st_centroid(geog);

-- Create index on the geom column.
create index if not exists phl_pwd_parcels__pt_geog__idx
on phl.pwd_parcels using gist(pt_geog);

--- BUS SHAPES ---

-- Add a column to bus_shapes table to store geography of each shape
alter table septa.bus_shapes
add column if not exists geog geography;

update septa.bus_shapes
set geog = st_makepoint(shape_pt_lon, shape_pt_lat, 4326)::geography;

-- Add index to geom column of septa.bus_shapes
create index if not exists septa_bus_shapes__geog__idx
on septa.bus_shapes using gist(geog);

-- Create a new shapes table to store the shape line geometries

create table septa.shape_geoms (
    shape_id text NOT NULL,
    shape_geom geometry('LINESTRING', 4326),
    CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);

create index shape_geoms_key_idx on septa.bus_shapes (shape_id);

-- Put shape data into shape_geoms to create lines

INSERT INTO septa.shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
    ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM septa.bus_shapes
GROUP BY shape_id;

--- STOP TIMES ---

DROP TABLE IF EXISTS septa.stop_times;

CREATE TABLE septa.stop_times
(
trip_id               TEXT,
arrival_time          DATE,
departure_time        DATE,
stop_id               TEXT,
stop_sequence         INTEGER
);

COPY septa.stop_times
FROM '"C:\Users\montb\Documents\MUSASpring\MUSA509\Data\gtfs_public\google_bus\stop_times.txt'
WITH (FORMAT csv, HEADER true);