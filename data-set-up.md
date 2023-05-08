ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=Assign2 user=postgres password=Wuzile19971210!" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "./PWD_PARCELS/PWD_PARCELS.shp"

remember to transfer the crs in sql

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=Assign2 user=postgres password=Wuzile19971210!" `
    -nln census.blockgroups_2020 `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "./tl_2020_42_bg/tl_2020_42_bg.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=Assign2 user=postgres password=Wuzile19971210!" `
    -nln azavea.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "./Neighborhoods_Philadelphia.geojson"

ALTER TABLE census.blockgroups_2020 ADD COLUMN geog_4326 geography(Geometry, 4326);
UPDATE census.blockgroups_2020 SET geog_4326 = ST_Transform(geog::geometry, 4326)::geography;
ALTER TABLE census.blockgroups_2020 DROP COLUMN geog;
ALTER TABLE census.blockgroups_2020 RENAME COLUMN geog_4326 TO geog;

SELECT ST_SRID(geog) FROM parcel;