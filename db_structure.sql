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
CREATE TABLE septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat TEXT,
    stop_lon TEXT,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding TEXT
);
ALTER TABLE septa.bus_stops
ALTER COLUMN stop_lat TYPE double precision
USING stop_lat::double precision;
ALTER TABLE septa.bus_stops
ALTER COLUMN stop_lon TYPE DOUBLE PRECISION
USING stop_lon :: DOUBLE PRECISION;
ALTER TABLE septa.bus_stops
ALTER COLUMN wheelchair_boarding TYPE INTEGER
USING wheelchair_boarding :: INTEGER;


CREATE TABLE septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);



CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat TEXT,
    shape_pt_lon TEXT,
    shape_pt_sequence INTEGER
);

ALTER TABLE septa.bus_shapes
ALTER COLUMN shape_pt_lat TYPE double precision
USING shape_pt_lat::double precision;
ALTER TABLE septa.bus_shapes
ALTER COLUMN shape_pt_lon TYPE DOUBLE PRECISION
USING shape_pt_lon :: DOUBLE PRECISION;


CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat TEXT,
    stop_lon TEXT,
    zone_id TEXT,
    stop_url TEXT
);

ALTER TABLE septa.rail_stops
ALTER COLUMN stop_lat TYPE double precision
USING stop_lat::double precision;
ALTER TABLE septa.rail_stops
ALTER COLUMN stop_lon TYPE DOUBLE PRECISION
USING stop_lon :: DOUBLE PRECISION;

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);




-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);
