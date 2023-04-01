WITH Meyerson AS
(SELECT *
FROM phl.campus_buildings
WHERE address = '220-30 S 34TH ST' )


SELECT geoid
FROM census.blockgroups_2020 block
INNER JOIN Meyerson
ON ST_Covers(ST_SetSRID(block.geog,4326), Meyerson.geog)