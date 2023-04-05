create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;
create extension if not exists postgis;

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
FROM 'D:\geo_ass2\google_bus\stops.txt'
WITH (FORMAT csv, HEADER true);

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
FROM 'D:\geo_ass2\google_bus\troutes.txt'
WITH (FORMAT csv, HEADER true);

CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);

COPY septa.bus_shapes
FROM 'D:\geo_ass2\google_bus\shapes.txt'
WITH (FORMAT csv, HEADER true);

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
FROM 'D:\geo_ass2\google_bus\trips.txt'
WITH (FORMAT csv, HEADER true);

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
FROM 'D:\geo_ass2\google_rail\stops.txt'
WITH (FORMAT csv, HEADER true);

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

COPY census.population_2020
FROM 'D:\geo_ass2\population.csv'
WITH (FORMAT csv, HEADER true);

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=ass2 user=postgres password=kiryuchan" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\geo_ass2\PWD_PARCELS\PWD_PARCELS.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=ass2 user=postgres password=kiryuchan" `
    -nln azavea.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\geo_ass2\geo-data-master (2)\geo-data-master\Neighborhoods_Philadelphia\Neighborhoods_Philadelphia.geojson"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=ass2 user=postgres password=kiryuchan" `
    -nln census.blockgroups_2020 `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\geo_ass2\tl_2020_42_bg\tl_2020_42_bg.shp"

CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

COPY census.population_2020
FROM 'D:\geo_ass2\population.csv'
WITH (FORMAT csv, HEADER true);

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=ass2 user=postgres password=kiryuchan" `
    -nln penn.boundary `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "D:\geo_ass2\Universities_Colleges-shp\ef7af340-1817-41f6-ad5b-032f11d6d7872020328-1-54q7hz.msruy.shp"

