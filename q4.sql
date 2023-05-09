WITH leng AS (
	select 
	DISTINCT shape_id,
	ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence))::geography)as shape_length,
	ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence))::geography as shape_geog
	from septa.bus_shapes
	group by shape_id
	ORDER BY shape_length DESC )

select
    DISTINCT sbt.route_id as route_short_name,
    sbt.trip_headsign as trip_headsign,
    leng.shape_geog as shape_geog,
 	leng. shape_length as shape_length
from septa.bus_trips as sbt
join leng on sbt.shape_id = leng.shape_id
order by shape_length desc
limit 2
