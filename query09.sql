WITH 
meyerson_hall AS (
  SELECT geog FROM phl.pwd_parcels
  WHERE brt_id = '883059600'
),

block_group AS (
  SELECT geoid AS geo_id
	FROM census.blockgroups_2020 
  WHERE ST_Contains(geog::geometry, (SELECT geog::geometry FROM meyerson_hall))
)

SELECT geo_id FROM block_group;