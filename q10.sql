with getpop as (
	select total, 
		right(pop.geoid, 12) as geoid,
		block.geog AS geog
		from census.population_2020 AS pop
		join census.blockgroups_2020 as block
		on right(pop.geoid, 12) = CAST(block.geoid AS text)
)

select stop_id,
    stop_name,
	CONCAT('Population Near THE STOP: ',CAST(getpop.total AS text)) AS stop_desc,
    stop_lon,
    stop_lat,
	rail.geog
	from septa.rail_stops AS rail
	join getpop
	on ST_Contains(getpop.geog:: geometry, rail.geog)

################################

 with cityhall as (
	select geoid, geog from census.blockgroups_2020
	where countyfp = '101' AND ogc_fid = '5190'
)

select stop_id,
    stop_name,
	CONCAT('Dist to City Hall: ',CAST(ROUND(CAST(ST_Distance(ST_centroid(cityhall.geog), rail.geog ) AS numeric), 4)AS text)) AS stop_desc,
    stop_lon,
    stop_lat,
	rail.geog
	from septa.rail_stops AS rail, cityhall
	ORDER BY stop_desc DESC