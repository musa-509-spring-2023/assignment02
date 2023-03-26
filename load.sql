ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=990328" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOM_TYPE=geography `
    -skipfailures`
    -lco GEOM_TYPE=geog `
    -overwrite `
    
    "\data\phl_pwd_parcels\PWD_PARCELS\PWD_PARCELS.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=990328" `
    -nln azavea.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=geography `-skipfailures`
    -overwrite `
    "data\Neighborhoods_Philadelphia\Neighborhoods_Philadelphia.geojson"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=990328" `
    -nln census.blockgroups_2020 `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "data\census_blockgroups_2020\tl_2020_42_bg.shp"