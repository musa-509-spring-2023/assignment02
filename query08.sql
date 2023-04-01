SELECT COUNT(*) count_block_groups
FROM phl.university u
LEFT JOIN census.blockgroups_2020 b
ON ST_Covers(u.geog, ST_SetSRID(b.geog,4326))