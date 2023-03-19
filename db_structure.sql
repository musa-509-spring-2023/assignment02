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

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS septa;
CREATE SCHEMA IF NOT EXISTS phl;
CREATE SCHEMA IF NOT EXISTS azavea;
CREATE SCHEMA IF NOT EXISTS census;

-- Enable postgis
CREATE EXTENSION IF NOT EXISTS postgis;

-- Load Data
-- SEPTA Bus stops
CREATE TABLE IF NOT EXISTS septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);

COPY septa.bus_stops
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\gtfs_public\google_bus\stops.txt'
WITH(FORMAT csv, HEADER true, DELIMITER ',');

-- SEPTA bus routes
CREATE TABLE IF NOT EXISTS septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);

COPY septa.bus_routes
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\gtfs_public\google_bus\routes.txt'
WITH(FORMAT csv, HEADER true, DELIMITER ',');

-- SEPTA bus trips
CREATE TABLE IF NOT EXISTS septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

COPY septa.bus_trips
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\gtfs_public\google_bus\trips.txt'
WITH(FORMAT csv, HEADER true, DELIMITER ',');


-- SEPTA bus shapes
CREATE TABLE IF NOT EXISTS septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\gtfs_public\google_bus\shapes.txt'
WITH(FORMAT csv, HEADER true, DELIMITER ',');

-- SEPTA rail stops
CREATE TABLE IF NOT EXISTS septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

COPY septa.rail_stops
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\gtfs_public\google_rail\stops.txt'
WITH(FORMAT csv, HEADER true, DELIMITER ',');

-- PHL PWD Parcels: OGR2OGR
-- Azavea Neighborhoods: OGR2OGR
-- CEnsus TIGER blockgroups 2020: OGR2OGR

-- Census Explorer 2020 population
CREATE TABLE IF NOT EXISTS census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

COPY census.population_2020
FROM 'C:\Users\radams\src\geospatial_cloudcomputing\assignment02\data\DECENNIALPL2020.P1_2023-02-26T182407\DECENNIALPL2020.P1-Data_firstThree.csv'
WITH(FORMAT csv, HEADER true, DELIMITER ',');

-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);

-- set parcels as 4326
update phl.pwd_parcels
set geog = st_setsrid(geog::geography, 4326)::geography;

-- create table for shapes
CREATE TABLE if not exists septa.shapes (
  shape_id text NOT NULL,
  shape_pt_lat double precision NOT NULL,
  shape_pt_lon double precision NOT NULL,
  shape_pt_sequence int NOT NULL
);

CREATE INDEX if not exists shapes_shape_key ON septa.shapes (shape_id);

-- Create a table to store the shape geometries
CREATE TABLE if not exists septa.shape_geogs (
  shape_id text NOT NULL,
  shape_geom geography('LINESTRING', 4326),
  CONSTRAINT shape_geog_pkey PRIMARY KEY (shape_id)
);

-- create index in shape_geogs table
CREATE INDEX if not exists shape_geog_key ON septa.shapes (shape_id);

-- create geog of bus shapes:
INSERT INTO septa.shape_geogs
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM septa.bus_shapes
GROUP BY shape_id;

--create spatial index of bus shapes:
create index if not exists septa_shapes__geog__idx
on septa.shape_geogs using gist
(shape_geom);