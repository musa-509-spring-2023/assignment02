WITH Meyerson AS (SELECT *
    FROM Phl.Campus_Buildings
    WHERE Address = '220-30 S 34TH ST'
)


SELECT Geoid
FROM Census.Blockgroups_2020 AS Block
INNER JOIN Meyerson
    ON ST_COVERS(ST_SETSRID(Block.Geog, 4326), Meyerson.Geog)
