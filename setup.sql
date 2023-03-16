CREATE EXTENSION postgis;

-- SEPTA BUS STOPS
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
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_bus/stops.txt'
WITH (FORMAT csv, HEADER true);

-- SEPTA BUS ROUTES
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
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_bus/routes.csv'
WITH (FORMAT csv, HEADER true);

-- SEPTA BUS TRIPS
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
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_bus/trips.csv'
WITH (FORMAT csv, HEADER true);

-- SEPTA BUS SHAPES
CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);
COPY septa.bus_shapes
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_bus/shapes.csv'
WITH (FORMAT csv, HEADER true);

-- SEPTA RAIL STOPS
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
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_rail/stops.csv'
WITH (FORMAT csv, HEADER true);

-- SEPTA CALENDAR
CREATE TABLE septa.calendar (
    monday INTEGER,
    tuesday INTEGER,
    wednesday INTEGER,
    thursday INTEGER,
    friday INTEGER,
    saturday INTEGER,
    sunday INTEGER
);
COPY septa.calendar
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/gtfs_public/google_bus/calendar.csv'
WITH (FORMAT csv, HEADER true);

-- CENSUS
CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);
COPY census.population_2020
FROM '/Users/myronbanez/Desktop/Coding/MUSA_509/assignment02/assignment02/DECENNIALPL2020.P1_2023-03-08T224849/census.csv'
WITH (FORMAT csv, HEADER true);
SELECT * FROM census.population_2020

-- SPATIAL DATA IMPORTED VIA PYTHON
SELECT * FROM phl.pwd_parcels
SELECT * FROM azavea.neighborhoods
SELECT * FROM census.blockgroups_2020

