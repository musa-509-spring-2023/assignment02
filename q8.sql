SELECT
    aza.name,
    COUNT(cens.ogc_fid) AS count_block_groups
FROM azavea.neighborhoods AS aza
LEFT JOIN census.blockgroups_2020 AS cens ON ST_CONTAINS(aza.geog::geometry, ST_TRANSFORM(ST_SETSRID(cens.geog::geometry, 4269), 4326))
WHERE aza.name = 'UNIVERSITY_CITY'
GROUP BY aza.name;
