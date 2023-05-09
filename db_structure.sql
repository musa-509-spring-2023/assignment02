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

---------------settings---------------------------------------------------------

CREATE IF NOT EXISTS extension postgis;

CREATE SCHEMA IF NOT EXISTS septa;
CREATE SCHEMA IF NOT EXISTS phl;
CREATE SCHEMA IF NOT EXISTS azavea;
CREATE SCHEMA IF NOT EXISTS census;

--------------------------------------------------------------------------------
---------------septa bus--------------------------------------------------------

DROP TABLE IF EXISTS septa.bus_stops;

CREATE TABLE septa.bus_stops (
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
FROM 'C:/Users/vestalk/Desktop/google_bus/stops.txt'
WITH (FORMAT csv, HEADER true);

-- Add a new geography column "geog" to the existing table
ALTER TABLE septa.bus_stops 
ADD COLUMN if not exists geog GEOGRAPHY(Point, 4326);

-- Update the "geog" column with geography data
UPDATE septa.bus_stops SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

--------------------------------------------------------------------------------
---------------septa bus route--------------------------------------------------

DROP TABLE IF EXISTS septa.bus_routes;

CREATE TABLE septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);


COPY septa.bus_routes
FROM 'C:/Users/vestalk/Desktop/google_bus/routes.csv'
WITH (FORMAT csv, HEADER true);

--------------------------------------------------------------------------------
---------------septa bus trips--------------------------------------------------

DROP TABLE IF EXISTS septa.bus_trips;

CREATE TABLE septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);

COPY septa.bus_trips
FROM 'C:/Users/vestalk/Desktop/google_bus/trips.csv'
WITH (FORMAT csv, HEADER true);

--------------------------------------------------------------------------------
---------------septa bus shapes--------------------------------------------------

DROP TABLE IF EXISTS septa.bus_shapes;

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM 'C:/Users/vestalk/Desktop/google_bus/shapes.csv'
WITH (FORMAT csv, HEADER true);

-------------------------------------------------------------------------------
---------------septa bus shapes--------------------------------------------------

DROP TABLE IF EXISTS septa.rail_stops;

CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

COPY septa.rail_stops
FROM 'C:/Users/vestalk/Desktop/google_bus/stops_rail.csv'
WITH (FORMAT csv, HEADER true);

-- Add a new geography column "geog" to the existing table
ALTER TABLE septa.rail_stops 
ADD COLUMN if not exists geog GEOGRAPHY(Point, 4326);

-- Update the "geog" column with geography data
UPDATE septa.rail_stops SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);


-------------------------------------------------------------------------------
---------------census pop------------------------------------------------------

DROP TABLE IF EXISTS census.population_2020;

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

DROP TABLE IF EXISTS temp_csv_import;

CREATE TEMP TABLE temp_csv_import (
    GEO_ID TEXT,
    NAME TEXT,
    P1_001N INTEGER);

COPY temp_csv_import (GEO_ID, NAME, P1_001N)
FROM 'C:/Users/vestalk/Desktop/123.csv'
WITH (FORMAT csv, HEADER true);

INSERT INTO census.population_2020 (geoid, geoname, total)
SELECT GEO_ID, NAME, P1_001N
FROM temp_csv_import;

DROP TABLE temp_csv_import;

UPDATE census.population_2020
SET geoid = REPLACE(geoid, '1500000US', '')

-------------------------------------------------------------------------------
---------------create spatial index !!!----------------------------------------


CREATE INDEX IF NOT EXISTS blockgroups_2020_geog_idx ON census.blockgroups_2020 USING GIST (geog);
CREATE INDEX IF NOT EXISTS neighborhoods_geog_idx ON azavea.neighborhoods USING GIST (geog);
CREATE INDEX IF NOT EXISTS bus_stops_geog_idx ON septa.bus_stops USING GIST (geog);
CREATE INDEX IF NOT EXISTS rail_stops_geog_idx ON septa.rail_stops USING GIST (geog);
CREATE INDEX IF NOT EXISTS pwd_parcels_geog_idx ON phl.pwd_parcels USING GIST (geog);

-------------------------------------------------------------------------------
---------------change srid!!!----------------------------------------


