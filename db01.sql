/* query 01 */

ALTER TABLE septa.bus_stops
DROP COLUMN IF EXISTS geom;
ALTER TABLE septa.bus_stops
ADD COLUMN geom geography(Point, 4326);
UPDATE septa.bus_stops SET geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;

ALTER TABLE census.blockgroups_2020
DROP COLUMN IF EXISTS geom;
ALTER TABLE census.blockgroups_2020
ADD COLUMN geom geometry(MultiPolygon, 3857);
UPDATE census.blockgroups_2020 SET geom = ST_Transform(geog::geometry, 3857);

/* query 03 */

ALTER TABLE phl.pwd_parcels
DROP COLUMN IF EXISTS geom;
ALTER TABLE phl.pwd_parcels
ADD COLUMN geom geography(Point, 4326);
UPDATE phl.pwd_parcels SET geom = ST_SetSRID(ST_Centroid(geog), 4326)::geography;

/* query 04 */

ALTER TABLE septa.bus_shapes
DROP COLUMN IF EXISTS geom2;
ALTER TABLE septa.bus_shapes
ADD COLUMN geom2 geography(Point, 4326);
UPDATE septa.bus_shapes SET geom2 = ST_SetSRID(geom, 4326)::geography;

/* query 05 */

ALTER TABLE azavea.neighborhoods
DROP COLUMN IF EXISTS geom;
ALTER TABLE azavea.neighborhoods
ADD COLUMN geom geography(MultiPolygon, 4326);
UPDATE azavea.neighborhoods SET geom = ST_SetSRID(geog, 4326)::geography;

/* query 10 */

ALTER TABLE septa.rail_stops
DROP COLUMN IF EXISTS geom;
ALTER TABLE septa.rail_stops
ADD COLUMN geom geography(Point, 4326);
UPDATE septa.rail_stops SET geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;


